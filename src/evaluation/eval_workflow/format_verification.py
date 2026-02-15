# evaluation/eval_workflow/format_verification.py
import shutil, re
from pathlib import Path
from .common import run

# -------- Terraform-level checks --------
def terraform_fmt(root: Path):
    """Run `terraform fmt -check -recursive`. Returns dict with pass flag."""
    rc, out, err = run("terraform fmt -check -recursive -no-color", root)
    error_msg = None
    if rc != 0:
        error_msg = "Formatting errors in:"
        if out:
            error_msg += f"\n{out}"
        if err:
            error_msg += f"\n{err}"
    return {
        "tool": "terraform-fmt",
        "rc": rc,
        "stdout": out,
        "stderr": err,
        "passed": rc == 0,
        "error_msg": error_msg
    }

def terraform_versions(root: Path):
    """Return Terraform version and provider version pins from lockfile."""
    if shutil.which("terraform") is None:
        return {"terraform_version": None, "providers": {}}
    rc, out, _ = run("terraform version", root)
    tfv = None
    m = re.search(r"Terraform\s+v([0-9.]+)", out or "")
    if m:
        tfv = m.group(1)
    providers = parse_lockfile_providers(root.joinpath(".terraform.lock.hcl"))
    return {"terraform_version": tfv, "providers": providers}

def parse_lockfile_providers(lockfile: Path) -> dict:
    """Best-effort parse of .terraform.lock.hcl → {provider: version}."""
    providers = {}
    if not lockfile.exists():
        return providers
    cur = None
    for line in lockfile.read_text(encoding="utf-8", errors="ignore").splitlines():
        m = re.match(r'\s*provider\s+"([^"]+)"\s*{', line)
        if m:
            cur = m.group(1)
            providers[cur] = {}
            continue
        if cur:
            mv = re.search(r'\bversion\s*=\s*"([^"]+)"', line)
            if mv:
                providers[cur]["version"] = mv.group(1)
            if line.strip() == "}":
                cur = None
    return {k: v.get("version", None) for k, v in providers.items()}

def terraform_graph(root: Path, artifacts: Path):
    """
    Run `terraform graph -no-color` for the configuration in `root` and
    write the DOT output to `<artifacts>/graph.dot`.
    """
    artifacts.mkdir(parents=True, exist_ok=True)

    if shutil.which("terraform") is None:
        return {"tool": "terraform-graph", "skipped": True, "reason": "terraform not installed"}

    rc, out, err = run("terraform graph -no-color", root)
    dot_path = artifacts / "graph.dot"

    if rc == 0 and out:
        try:
            dot_path.write_text(out, encoding="utf-8")
        except Exception as e:
            return {
                "tool": "terraform-graph",
                "rc": rc,
                "stderr": f"{err or ''}\nwrite_error: {e}",
                "passed": False,
                "dot": None,
            }

    return {
        "tool": "terraform-graph",
        "rc": rc,
        "stdout": out,
        "stderr": err,
        "passed": rc == 0,
        "dot": str(dot_path) if dot_path.exists() else None,
    }
