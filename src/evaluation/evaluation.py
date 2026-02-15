# evaluation/evaluation.py
"""
Evaluation-only pipeline for Terraform trees.

Purpose
-------
Run a reproducible, self-contained evaluation for each Terraform root under a
given directory. No cross-tree comparison is performed here. The script emits
per-root artifacts and a run-level json you can compare later.
"""

import os, json, hashlib, re
from pathlib import Path
from datetime import datetime
import sys
from dotenv import load_dotenv

# Add the current directory to sys.path so eval_workflow can be imported
sys.path.insert(0, str(Path(__file__).parent.resolve()))

# Load environment variables
load_dotenv()

from eval_workflow.format_verification import terraform_fmt, terraform_versions, terraform_graph
from eval_workflow.schema_checking import tflint, checkov
from eval_workflow.live_deployment import (
    terraform_validate, plan_json, 
    apply_tf_in_localstack, start_localstack, stop_localstack
)

# -------- Config defaults --------
DEFAULT_EVAL_DIR = Path(__file__).resolve().parent.joinpath("../../workspace/1067203/").resolve()
OUTPUT_EVAL_DIR = Path(__file__).resolve().parent.joinpath("../../log/1067203/").resolve()

def get_eval_dir() -> Path:
    """Resolve evaluation root directory from CLI arg, then EVAL_DIR, then default."""
    if len(sys.argv) > 1 and sys.argv[1].strip():
        return Path(sys.argv[1]).resolve()
    env = os.getenv("EVAL_DIR")
    return Path(env).resolve() if env else DEFAULT_EVAL_DIR

def ensure_dir(p: Path) -> Path:
    """Create directory if missing. Return the path."""
    p.mkdir(parents=True, exist_ok=True)
    return p

def slug_for_root(base: Path, root: Path) -> str:
    """Make a filesystem-safe slug from a root path relative to base."""
    try:
        rel = root.relative_to(base).as_posix()
    except Exception:
        rel = re.sub(r"[:/\\]+", "_", str(root))
    return re.sub(r"[^A-Za-z0-9_.-]+", "_", rel).strip("_") or "root"

def _has_tf_here(d: Path) -> bool:
    return any(d.glob("*.tf")) or any(d.glob("*.tf.json"))

def sha256_file(p: Path) -> str:
    """SHA256 of a file."""
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def _roots_from_targets(eval_dir: Path, targets_csv: str) -> list[Path]:
    targets = [t.strip() for t in (targets_csv or "").split(",") if t.strip()]
    roots: list[Path] = []
    for t in targets:
        p = Path(t)
        if not p.is_absolute():
            p = (eval_dir / t)
        p = p.resolve()
        if p.is_dir() and _has_tf_here(p):
            roots.append(p)
    # de-dup
    return sorted({r for r in roots})

def sha256_many(paths: list[Path]) -> str | None:
    """Stable hash of multiple files (names + content)."""
    if not paths:
        return None
    h = hashlib.sha256()
    for p in sorted(paths):
        h.update(p.name.encode()); h.update(b"\0")
        h.update(sha256_file(p).encode()); h.update(b"\0")
    return h.hexdigest()

def find_tf_roots(root: Path):
    """Discover distinct Terraform roots under `root` by locating *.tf or *.tf.json parents."""
    roots = set()
    for p in root.rglob("*.tf"):
        if ".terraform" in p.parts:
            continue
        roots.add(p.parent.resolve())
    for p in root.rglob("*.tf.json"):
        if ".terraform" in p.parts:
            continue
        roots.add(p.parent.resolve())
    return sorted(roots)

# -------- One-root evaluation (no comparisons) --------
def eval_root(root: Path, artifacts_root: Path, run_id: str, repo_id: str, repo_url: str | None = None) -> dict:
    """Execute the evaluation workflow for a single Terraform root."""
    artifacts = ensure_dir(artifacts_root)
    errors = []

    # Run metadata
    versions = terraform_versions(root)
    region = os.getenv("EVAL_AWS_REGION", "us-east-1")

    # Normalize
    fmt_res = terraform_fmt(root)
    val_res = terraform_validate(root)
    graph_res = terraform_graph(root, artifacts)

    # Static analysis
    tflint_res = tflint(root, artifacts)
    checkov_res = checkov(root, artifacts)

    # Plan
    plan_res = plan_json(root, artifacts)

    # Policy as code (disabled for now)
    # policy_res = {"tool": "conftest", "skipped": True}
    # if plan_res.get("plan_ok") and plan_res.get("plan_json_path"):
    #     policy_res = conftest_policy(Path(plan_res["plan_json_path"]), artifacts)

    # Apply TF smoke
    idem_res = apply_tf_in_localstack(root, artifacts)

    # Collect specific error messages from each step
    if not val_res.get("passed"):
        errors.append(f"Validation: {val_res.get('error_msg', 'unknown error')}")
    
    if not plan_res.get("plan_ok"):
        errors.append(f"Plan: {plan_res.get('error_msg', 'unknown error')}")
        
    if idem_res.get("error_msg"):
        errors.append(f"Apply: {idem_res['error_msg']}")

    # Flatten metrics for JSONL
    metrics = {
        # Run metadata
        "run_id": run_id,
        "repo_id": repo_id,
        "repo_url": repo_url,
        "timestamp": datetime.now().isoformat(timespec="seconds"),
        "terraform_version": versions.get("terraform_version"),
        "provider_versions": json.dumps(versions.get("providers") or {}),
        "region": region,

        # format_verification
        "tf_fmt_ok": fmt_res.get("passed"),
        "tf_validate_ok": val_res.get("passed"),
        "tf_graph_generated": graph_res.get("rc") == 0,

        # schema_checking
        "tflint_pass": tflint_res.get("passed") if "skipped" not in tflint_res else None,
        "tflint_critical": (tflint_res.get("counts") or {}).get("critical") if "skipped" not in tflint_res else None,
        "tflint_high": (tflint_res.get("counts") or {}).get("high") if "skipped" not in tflint_res else None,
        "tflint_medium": (tflint_res.get("counts") or {}).get("medium") if "skipped" not in tflint_res else None,
        "tflint_low": (tflint_res.get("counts") or {}).get("low") if "skipped" not in tflint_res else None,
        "checkov_pass": checkov_res.get("passed") if "skipped" not in checkov_res else None,
        "checkov_score": checkov_res.get("checkov_score") if "skipped" not in checkov_res else None,

        # live_deployment
        "tf_init_ok": val_res.get("init_rc") == 0,
        "tf_plan_ok": plan_res.get("plan_ok"),
        "resources_planned_count": plan_res.get("resources_planned_count"),

        # Policy-as-code
        #"policy_pass": (policy_res.get("passed") if "skipped" not in policy_res else "disabled"),
        #"violations_total": (policy_res.get("violations_total") if "skipped" not in policy_res else 0),

        # Tests (not executed here)
        "tests_total": "no tests",

        # Idempotence smoke test
        "apply_ok": (None if idem_res.get("skipped") else idem_res.get("apply_ok")),
        "apply_unsupported_resources": (idem_res.get("unsupported_resources") if idem_res.get("skipped") else None),

        # Add error messages to metrics
        "errors": errors,
        "error_details": {
            "validation": val_res.get("error_msg"),
            "plan": plan_res.get("error_msg"),
            "apply": idem_res.get("error_msg")
        },
        "has_errors": bool(errors),
    }

    (artifacts / "metrics.json").write_text(json.dumps(metrics, ensure_ascii=False, indent=2), encoding="utf-8")
    return metrics

def evaluate_dir(eval_dir: Path | str, output_eval_dir: Path | str, repo_url: str | None = None) -> dict:
    # Accept either Path or string input and coerce to Path objects
    eval_dir = Path(eval_dir)
    output_eval_dir = Path(output_eval_dir)
    if not eval_dir.exists():
        raise RuntimeError(f"Eval directory not found: {eval_dir}")

    # 1) Highest priority: explicit targets via env (set by analyze_source stage)
    roots: list[Path] = []
    targets_csv = os.getenv("EVAL_TARGETS", "").strip()
    if targets_csv:
        roots = _roots_from_targets(eval_dir, targets_csv)

    # 2) Next: /gate.json from analyze_source (recommended_roots)
    if not roots:
        gate_path = (output_eval_dir / "gate.json")
        if gate_path.exists():
            try:
                gate = json.loads(gate_path.read_text(encoding="utf-8"))
                rec = gate.get("recommended_roots") or []
                roots = _roots_from_targets(eval_dir, ",".join(rec))
            except Exception:
                roots = []

    # 3) Fallback: auto-discover
    if not roots:
        roots = [eval_dir.resolve()] if _has_tf_here(eval_dir) else find_tf_roots(eval_dir)

    if not roots:
        raise RuntimeError(f"No Terraform files under: {eval_dir}")

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    run_id = ts
    report_dir = ensure_dir(output_eval_dir / f"run_{ts}")
    jsonl_path = report_dir / f"tf_eval_{ts}.jsonl"

    rows = []
    errors = []
    error_details = {}
    ls_cid = start_localstack()
    try:
        with open(jsonl_path, "w", encoding="utf-8") as jf:
            for r in roots:
                slug = slug_for_root(eval_dir, r)
                artifacts = ensure_dir(report_dir / slug)

                parts = r.parts
                repo_id = parts[-3] if len(parts) >= 3 else slug

                metrics = eval_root(r, artifacts, run_id, repo_id, repo_url)
                if metrics.get("errors"):
                    errors.extend(metrics["errors"])
                    error_details[slug] = metrics.get("error_details", {})
                jf.write(json.dumps(metrics, ensure_ascii=False) + "\n")
                rows.append(metrics)
    finally:
        if ls_cid:
            stop_localstack(ls_cid)

    ok = all(bool(m.get("tf_plan_ok")) for m in rows) if rows else False
    return {
        "ok": ok,
        "run_id": run_id,
        "report_dir": str(report_dir),
        "jsonl": str(jsonl_path),
        "count": len(rows),
        "errors": errors,
        "error_details": error_details,
        "has_errors": bool(errors)
    }

# -------- CLI entry (optional) --------
def main():
    res = evaluate_dir(get_eval_dir(), OUTPUT_EVAL_DIR)
    print("\nEvaluation artifacts:")
    print(f"- JSONL: {res['jsonl']}")
    print(f"- Per-root artifacts under: {res['report_dir']}")

if __name__ == "__main__":
    main()
