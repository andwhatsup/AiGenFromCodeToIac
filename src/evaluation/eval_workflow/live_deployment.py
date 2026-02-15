# evaluation/eval_workflow/live_deployment.py
from __future__ import annotations

import json
import os
import re
import shlex
import shutil
import time
from pathlib import Path
from typing import Any

from .common import run

# --- Config ---
POLICY_DIR = os.getenv("POLICY_DIR")
LOCALSTACK_CONTAINER = "terraform-eval-localstack"
LS_ENDPOINT = os.getenv("LS_ENDPOINT", "http://localhost:4566")
EVAL_DEBUG = os.getenv("EVAL_DEBUG", "1") == "1"
APPLY_TIMEOUT_SECONDS = int(os.getenv("APPLY_TIMEOUT_SECONDS", "180"))  # 3 minutes

# Per-root guards and caches
_APPLIED_ROOTS: set[str] = set()
_INITED_ROOTS: set[str] = set()
_PREPPED_ROOTS: set[str] = set()
_ALLOW_MULTI = os.getenv("EVAL_ALLOW_MULTI_APPLY", "0") == "1"
_REQUIRED_PROVIDERS_RE = re.compile(r"\brequired_providers\b", re.IGNORECASE)
_HAS_AWS_PROVIDER_RE = re.compile(r'provider\s*"aws"\s*{', re.IGNORECASE)

# If you want to skip apply when plan contains unsupported types, populate this set elsewhere.
UNSUPPORTED_IN_LOCALSTACK: set[str] = set()


def _log(msg: str) -> None:
    if EVAL_DEBUG:
        print(f"[live] {msg}")


def _get_localstack_logs(num_lines: int = 100) -> str:
    """Retrieve last N lines from LocalStack container logs."""
    try:
        rc, logs, _ = run(f"docker logs --tail {num_lines} {LOCALSTACK_CONTAINER}", Path.cwd())
        if rc == 0:
            return logs or ""
    except Exception as e:
        _log(f"failed to retrieve LocalStack logs: {e}")
    return ""


# ------------------------- Common helpers -------------------------

def _root_key(root: Path) -> str:
    return str(Path(root).resolve())


def _terraform_available() -> bool:
    return shutil.which("terraform") is not None


def _prep_env(env_extra: dict | None = None) -> dict[str, str]:
    env = os.environ.copy()
    region = os.getenv("EVAL_AWS_REGION", "us-east-1")
    env.update({
        "TF_IN_AUTOMATION": "1",
        "TF_CLI_CONFIG_FILE": "",
        "TF_INPUT": "0",
        "TF_CLI_ARGS": "",
        "TF_CLI_ARGS_init": "",

        # AWS (LocalStack) defaults
        "AWS_ACCESS_KEY_ID": os.getenv("AWS_ACCESS_KEY_ID", "mock"),
        "AWS_SECRET_ACCESS_KEY": os.getenv("AWS_SECRET_ACCESS_KEY", "mock"),
        "AWS_SESSION_TOKEN": os.getenv("AWS_SESSION_TOKEN", "mock"),
        "AWS_DEFAULT_REGION": region,
        "AWS_REGION": region,
        "AWS_EC2_METADATA_DISABLED": "true",
        "AWS_STS_REGIONAL_ENDPOINTS": "regional",
        "AWS_SKIP_REGION_VALIDATION": "true",
        "AWS_SKIP_CREDENTIALS_VALIDATION": "true",
        "AWS_SKIP_METADATA_API_CHECK": "true",
        "AWS_SKIP_REQUESTING_ACCOUNT_ID": "true",

        # Terraform/provider
        "TF_SKIP_PROVIDER_VERIFY": "1",

        # LocalStack endpoints/quirks
        "AWS_ENDPOINT_URL": LS_ENDPOINT,
        "AWS_ALLOW_FAKE_CREDENTIALS": "true",
        "AWS_S3_FORCE_PATH_STYLE": "true",
        "S3_USE_PATH_STYLE": "true",
    })

    tok = os.getenv("LOCALSTACK_AUTH_TOKEN", "")
    if tok:
        env["LOCALSTACK_AUTH_TOKEN"] = tok
    if env_extra:
        env.update(env_extra)
    return env


def _ensure_plugin_cache(artifacts: Path, env: dict[str, str]) -> None:
    cache = (artifacts / ".tf_plugin_cache").resolve()
    cache.mkdir(parents=True, exist_ok=True)
    env["TF_PLUGIN_CACHE_DIR"] = str(cache)


def _autofix_legacy_tags(root: Path) -> int:
    n = 0
    for tf in root.glob("*.tf"):
        try:
            txt = tf.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        new = re.sub(r"(^\s*tags\s*\{)", r"tags = {", txt, flags=re.MULTILINE)
        if new != txt:
            tf.write_text(new, encoding="utf-8")
            n += 1
    return n

def _root_tf_files(root: Path) -> list[Path]:
    return list(root.glob("*.tf")) + list(root.glob("*.tf.json"))

def _autofix_eip_vpc_flag(root: Path) -> int:
    n = 0
    for tf in root.glob("*.tf"):
        try:
            txt = tf.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        new = re.sub(r"(?m)^\s*vpc\s*=\s*true\s*$\n?", "", txt)
        if new != txt:
            tf.write_text(new, encoding="utf-8")
            n += 1
    return n


def _prep_root_once(root: Path) -> None:
    """One-time per-root: quick text fixes + fmt."""
    key = _root_key(root)
    if key in _PREPPED_ROOTS:
        return

    patched_tags = _autofix_legacy_tags(root)
    if patched_tags:
        _log(f"autofix: patched tags in {patched_tags} file(s) under {root}")

    patched_eip = _autofix_eip_vpc_flag(root)
    if patched_eip:
        _log(f"autofix: removed legacy aws_eip vpc flag in {patched_eip} file(s) under {root}")

    run("terraform fmt -recursive -no-color", root)
    _PREPPED_ROOTS.add(key)


def _repo_declares_nonlocal_backend(root: Path) -> bool:
    patt = re.compile(r'terraform\s*{[^}]*backend\s*"([^"]+)"', re.IGNORECASE | re.DOTALL)
    for tf in root.glob("*.tf"):
        try:
            text = tf.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for m in patt.finditer(text):
            btype = (m.group(1) or "").strip().lower()
            if btype and btype != "local":
                return True
    return False


def _ensure_init(root: Path, env: dict[str, str], artifacts: Path, phase: str) -> tuple[int, str, str]:
    """Run terraform init once per root (cached)."""
    key = _root_key(root)
    if key in _INITED_ROOTS:
        return 0, "", ""

    # Clean stale TF data and pin TF_DATA_DIR
    tfdata = root / ".terraform"
    if tfdata.exists():
        shutil.rmtree(tfdata, ignore_errors=True)
    env["TF_DATA_DIR"] = str(tfdata.resolve())
    
    lockfile = root / ".terraform.lock.hcl"

    if lockfile.exists():
        try:
            lockfile.unlink()
        except Exception:
            pass
    
    create_required_providers_override(root)
    create_aws_provider_override(root)

    if _repo_declares_nonlocal_backend(root):
        create_backend_local_override(root)

    _ensure_plugin_cache(artifacts, env)

    cmd = "terraform init -reconfigure -upgrade -input=false -no-color"
    rc, out, err = run(cmd, root, env)
    _log(f"{phase} init rc={rc}")
    if rc != 0:
        msg = (out or "") + "\n" + (err or "")
        if "Inconsistent dependency lock file" in msg or "no version is selected" in msg:
            if lockfile.exists():
                try:
                    lockfile.unlink()
                except Exception:
                    pass
            rc, out, err = run(cmd, root, env)
            _log(f"{phase} init retry(after lockfile reset) rc={rc}")
    if rc == 0:
        _INITED_ROOTS.add(key)
    return rc, out, err


def _write_text(path: Path, content: str | None) -> None:
    path.write_text(content or "", encoding="utf-8")


def _load_json_maybe(path: Path) -> dict[str, Any]:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def _plan_has_unsupported(plan_json_path: Path) -> list[str]:
    data = _load_json_maybe(plan_json_path)
    types: set[str] = set()

    def walk(m: dict) -> None:
        if not m:
            return
        for r in (m.get("resources") or []):
            t = r.get("type")
            if t:
                types.add(t)
        for ch in (m.get("child_modules") or []):
            walk(ch)

    walk(((data.get("planned_values") or {}).get("root_module")) or {})
    return sorted(t for t in types if t in UNSUPPORTED_IN_LOCALSTACK)

def count_resources_from_plan(plan: dict) -> int:
    def walk_mod(m: dict) -> int:
        if not m:
            return 0
        c = len(m.get("resources") or [])
        for ch in (m.get("child_modules") or []):
            c += walk_mod(ch)
        return c

    planned = plan.get("planned_values", {}) or {}
    return walk_mod(planned.get("root_module") or {})


def _terraform_plan_to_json(root: Path, artifacts: Path, env: dict[str, str]) -> dict[str, Any]:
    """
    PLAN #1 (artifact plan): terraform plan -out + terraform show -json -> artifacts/plan.json
    Returns init/plan/show rcs and plan_ok, plus resources_planned_count.
    """
    rc_i, _, err_i = _ensure_init(root, env, artifacts, phase="plan")

    planfile = root / ".tfplan.tmp"
    cmd_plan = f"terraform plan -out={shlex.quote(str(planfile))} -lock=false -input=false -no-color"
    rc_p, out_p, err_p = run(cmd_plan, root, env)
    _log(f"terraform plan rc={rc_p}")

    _write_text(artifacts / "plan_stdout.txt", out_p)
    _write_text(artifacts / "plan_stderr.txt", err_p)

    plan_json_str = "{}"
    rc_s, err_s = 1, ""
    if rc_i == 0 and rc_p == 0:
        cmd_show = f"terraform show -json {shlex.quote(str(planfile))}"
        rc_s, out_s, err_s = run(cmd_show, root, env)
        _log(f"terraform show rc={rc_s}")
        _write_text(artifacts / "show_stderr.txt", err_s)
        plan_json_str = out_s or "{}"

    plan_json_path = artifacts / "plan.json"
    plan_json_path.write_text(plan_json_str if plan_json_str else "{}", encoding="utf-8")

    try:
        if planfile.exists():
            planfile.unlink()
    except Exception:
        pass

    error_msg = None
    if rc_i != 0:
        error_msg = f"Init failed: {err_i}"
    elif rc_p != 0:
        error_msg = f"Plan failed: {err_p if err_p else out_p}"
    elif rc_s != 0:
        error_msg = f"Show plan failed: {err_s}"

    data = {}
    try:
        data = json.loads(plan_json_str) if plan_json_str else {}
    except Exception:
        data = {}

    return {
        "init_rc": rc_i,
        "plan_rc": rc_p,
        "show_rc": rc_s,
        "plan_stdout": out_p,
        "plan_stderr": err_p,
        "show_stderr": err_s,
        "plan_json_path": str(plan_json_path),
        "plan_ok": (rc_i == 0 and rc_p == 0 and rc_s == 0),
        "error_msg": error_msg,
        "resources_planned_count": count_resources_from_plan(data),
    }


def _terraform_plan_detailed_exitcode(root: Path, artifacts: Path, env: dict[str, str]) -> dict[str, Any]:
    """
    PLAN #2 (idempotence check): terraform plan -detailed-exitcode
      rc=0 => no changes
      rc=2 => changes present
      rc=1 => error
    """
    rc, out, err = run("terraform plan -detailed-exitcode -input=false -no-color", root, env)
    _log(f"second plan rc={rc}")
    _write_text(artifacts / "second_plan_stdout.txt", out)
    _write_text(artifacts / "second_plan_stderr.txt", err)

    # changes: try parse summary; if rc==0, changes=0 is safe
    changes = None
    if rc == 0:
        changes = 0
    else:
        m = re.search(r"(\d+)\s+to add,\s+(\d+)\s+to change,\s+(\d+)\s+to destroy", out or "")
        if m and rc in (0, 2):
            changes = sum(int(x) for x in m.groups())

    return {
        "second_plan_rc": rc,
        "second_plan_changes": changes,
        "idempotent": (rc == 0),
    }


# ------------------------- Public steps -------------------------

def terraform_validate(root: Path, env_extra: dict | None = None):
    _log(f"terraform_validate: root={root}")
    if not _terraform_available():
        return {"tool": "terraform", "skipped": True, "reason": "terraform not installed", "passed": False}

    _prep_root_once(root)
    env = _prep_env(env_extra)

    # Store init logs in-root (keeps signature unchanged)
    artifacts = root
    rc_i, out_i, err_i = _ensure_init(root, env, artifacts, phase="validate")
    _write_text(artifacts / "init_validate_stdout.txt", out_i)
    _write_text(artifacts / "init_validate_stderr.txt", err_i)

    rc_v, out_v, err_v = run("terraform validate -no-color", root, env)
    _log(f"terraform validate rc={rc_v}")
    _write_text(artifacts / "validate_stdout.txt", out_v)
    _write_text(artifacts / "validate_stderr.txt", err_v)

    error_msg = None
    if rc_i != 0:
        error_msg = f"Init failed: {err_i}"
    elif rc_v != 0:
        error_msg = f"Validation failed: {err_v if err_v else out_v}"

    return {
        "tool": "terraform",
        "init_rc": rc_i,
        "validate_rc": rc_v,
        "validate_stdout": out_v,
        "validate_stderr": err_v,
        "passed": (rc_i == 0 and rc_v == 0),
        "error_msg": error_msg,
    }


def plan_json(root: Path, artifacts: Path, env_extra: dict | None = None):
    _log(f"plan_json: root={root}")
    if not _terraform_available():
        return {"skipped": True, "reason": "terraform not installed", "plan_ok": False}

    _prep_root_once(root)
    env = _prep_env(env_extra)
    _ensure_plugin_cache(artifacts, env)

    return _terraform_plan_to_json(root, artifacts, env)


def conftest_policy(plan_json_path: Path, artifacts: Path):
    if not POLICY_DIR or shutil.which("conftest") is None:
        return {"tool": "conftest", "skipped": True, "reason": "missing policy or conftest not installed"}
    if not Path(POLICY_DIR).exists():
        return {"tool": "conftest", "skipped": True, "reason": f"policy dir not found: {POLICY_DIR}"}

    rc, out, err = run(
        f"conftest test --no-color -o json --input=json {shlex.quote(str(plan_json_path))} -p {shlex.quote(POLICY_DIR)}",
        plan_json_path.parent,
    )
    (artifacts / "policy.json").write_text(out or "", encoding="utf-8")

    try:
        data = json.loads(out) if out else []
    except Exception:
        data = []

    violations, by_rule = 0, {}
    for file_res in data:
        for fail in (file_res.get("failures", []) or []):
            violations += 1
            rid = fail.get("metadata", {}).get("id") or fail.get("msg") or "unknown"
            by_rule[rid] = by_rule.get(rid, 0) + 1

    return {
        "tool": "conftest",
        "rc": rc,
        "json": data,
        "stderr": err,
        "passed": (rc == 0),
        "violations_total": violations,
        "violations_by_rule": by_rule,
    }


def apply_tf_in_localstack(root: Path, artifacts: Path):
    _log(f"apply_tf_in_localstack: root={root}")
    if not _terraform_available():
        _log("skip apply: terraform missing")
        return {"skipped": True, "reason": "terraform not installed"}

    key = _root_key(root)
    if not _ALLOW_MULTI and key in _APPLIED_ROOTS:
        _log(f"skip apply: already applied once for root {key}")
        return {"skipped": True, "reason": "apply_once_per_root guard"}

    plan_path = artifacts / "plan.json"
    if not plan_path.exists():
        _log("skip apply: no plan.json")
        return {"skipped": True, "reason": "no plan.json"}
    plan_text = plan_path.read_text(encoding="utf-8", errors="ignore").strip()
    if plan_text in ("", "{}"):
        _log("skip apply: empty plan.json (plan failed)")
        return {"skipped": True, "reason": "empty plan.json (plan failed)"}
    
    unsupported = _plan_has_unsupported(plan_path)
    if unsupported:
        _log(f"skip apply: unsupported in LocalStack: {', '.join(unsupported)}")
        return {
            "skipped": True,
            "reason": "unsupported services in LocalStack",
            "unsupported_resources": unsupported,
        }

    _prep_root_once(root)
    env = _prep_env(None)
    _ensure_plugin_cache(artifacts, env)

    rc_i, _, err_i = _ensure_init(root, env, artifacts, phase="apply")
    if rc_i != 0:
        return {"apply_rc": rc_i, "apply_ok": False, "reason": f"init failed: {err_i}"}

    # Clean state files to avoid contamination
    for f in ("terraform.tfstate", "terraform.tfstate.backup"):
        p = root / f
        if p.exists():
            p.unlink()

    _APPLIED_ROOTS.add(key)

    # Run apply with timeout (3 minutes by default)
    apply_cmd = "terraform apply -auto-approve -input=false -no-color"
    rc_a, out_a, err_a = run(apply_cmd, root, env, timeout_s=APPLY_TIMEOUT_SECONDS)
    _write_text(artifacts / "apply_stdout.txt", out_a)
    _write_text(artifacts / "apply_stderr.txt", err_a)
    _log(f"apply rc={rc_a}")

    # Check for timeout exit code (124 for GNU timeout)
    if rc_a == 124:
        _log(f"apply timed out after {APPLY_TIMEOUT_SECONDS}s, fetching LocalStack logs")
        ls_logs = _get_localstack_logs(num_lines=150)
        _write_text(artifacts / "localstack_logs_on_timeout.txt", ls_logs)
        return {
            "apply_rc": 124,
            "apply_ok": False,
            "reason": f"apply timed out after {APPLY_TIMEOUT_SECONDS}s",
            "localstack_logs_available": bool(ls_logs),
        }

    if rc_a != 0:
        return {"apply_rc": rc_a, "apply_ok": False}

    # PLAN #2 (idempotence/drift check)
    second = _terraform_plan_detailed_exitcode(root, artifacts, env)

    return {
        "apply_rc": rc_a,
        "apply_ok": (rc_a == 0),
        **second,
    }


# ------------------------- Provider override & LocalStack -------------------------

def root_has_required_providers(root: Path) -> bool:
    for f in _root_tf_files(root):
        try:
            if _REQUIRED_PROVIDERS_RE.search(f.read_text(encoding="utf-8", errors="ignore")):
                return True
        except Exception:
            pass
    return False


def root_has_aws_provider_block(root: Path) -> bool:
    for f in _root_tf_files(root):
        try:
            if _HAS_AWS_PROVIDER_RE.search(f.read_text(encoding="utf-8", errors="ignore")):
                return True
        except Exception:
            pass
    return False

def create_required_providers_override(root: Path) -> Path:
    template_path = Path(__file__).parent / "override_required_provider.tf"
    if not template_path.exists():
        raise FileNotFoundError(f"Required providers template not found at {template_path}")

    override_file = root / "_eval_override_required_providers.tf"
    if not root_has_required_providers(root) and not override_file.exists():
        _log(f"create_required_providers_override: src={template_path} dest={override_file}")
        shutil.copy2(template_path, override_file)
    return override_file

def create_aws_provider_override(root: Path) -> Path:
    template_path = Path(__file__).parent / "override_aws_provider.tf"
    if not template_path.exists():
        raise FileNotFoundError(f"AWS provider override template not found at {template_path}")

    override_file = root / "_eval_override_aws_provider.tf"
    if not root_has_aws_provider_block(root) and not override_file.exists():
        _log(f"create_aws_provider_override: src={template_path} dest={override_file}")
        shutil.copy2(template_path, override_file)
    return override_file

def create_backend_local_override(root: Path) -> Path:
    """
    Force local backend for evaluation by shadowing any remote backend blocks.
    Terraform allows multiple `terraform {}` blocks; backend selection is resolved at init.
    """
    override = root / "backend_override.tf"
    if not override.exists():
        override.write_text('terraform {\n  backend "local" {}\n}\n', encoding="utf-8")
        _log(f"created backend override at {override}")
    return override


def start_localstack() -> str | None:
    _log(f"starting LocalStack docker; auth_token={'set' if os.getenv('LOCALSTACK_AUTH_TOKEN') else 'unset'} endpoint={LS_ENDPOINT}")
    if shutil.which("docker") is None:
        print("[localstack] docker not found, skipping")
        return None

    rc, out, _ = run(f"docker ps -q -f name={LOCALSTACK_CONTAINER}", Path.cwd())
    if out.strip():
        _log(f"reusing container {LOCALSTACK_CONTAINER} cid={out.strip()}")
        return out.strip()

    env_flag = ""
    if os.getenv("LOCALSTACK_AUTH_TOKEN"):
        env_flag = f"-e LOCALSTACK_AUTH_TOKEN={os.getenv('LOCALSTACK_AUTH_TOKEN')} "

    _log("docker run localstack/localstack-pro:latest -p 4566 -p 4510-4559")
    rc, cid, err = run(
        f"docker run -d --rm -p 4566:4566 -p 4510-4559:4510-4559 "
        f"-v /var/run/docker.sock:/var/run/docker.sock "
        f"{env_flag}--name {LOCALSTACK_CONTAINER} localstack/localstack-pro:latest",
        Path.cwd(),
    )
    _log(f"docker run rc={rc} cid={(cid or '').strip()} err={(err or '').strip()[:200]}")
    if rc != 0:
        print(f"[localstack] failed to start: {err}")
        return None

    _log("waiting for LocalStack to be ready...")
    for _ in range(60):
        _rc, logs, _ = run(f"docker logs --tail 50 {LOCALSTACK_CONTAINER}", Path.cwd())
        if "Ready." in logs or "Ready to accept" in logs or "Running on" in logs:
            _log("LocalStack ready")
            break
        time.sleep(1)

    return (cid or "").strip()


def stop_localstack(container_hint: str | None) -> None:
    _log(f"stopping LocalStack container name={LOCALSTACK_CONTAINER}")
    if shutil.which("docker") is None:
        return
    if not container_hint:
        return
    run(f"docker stop {LOCALSTACK_CONTAINER}", Path.cwd())
