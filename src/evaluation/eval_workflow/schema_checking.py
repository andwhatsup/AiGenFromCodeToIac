# evaluation/eval_workflow/schema_checking.py
import json
import shutil
from pathlib import Path

from .common import run


# -------- Static analysis --------
# -------- Here is a bug with the severity levels, tflint only uses ERROR/WARNING/NOTICE --------
def tflint(root: Path, artifacts: Path):
    """
    Run `tflint --format json`. Save raw JSON. Return severity counts and pass flag.
    Note: tflint rc==0 means no issues at the selected severity thresholds.
    """
    if shutil.which("tflint") is None:
        return {"tool": "tflint", "skipped": True, "reason": "tflint not installed"}

    rc, out, err = run("tflint --format json --no-color", root)

    data = None
    try:
        data = json.loads(out) if out else None
    except Exception:
        data = None

    (artifacts / "tflint.json").write_text(out or "", encoding="utf-8")

    issues = []
    if isinstance(data, dict) and "issues" in data:
        issues = data["issues"]
    elif isinstance(data, list):
        issues = data

    sev_map = {"ERROR": "high", "WARNING": "medium", "NOTICE": "low"}  # (optional: keep INFO as fallback)
    counts = {"critical": 0, "high": 0, "medium": 0, "low": 0}

    for it in issues or []:
        sev = (
            it.get("severity")
            or (it.get("rule") or {}).get("severity")
            or ""
        ).upper()
        level = sev_map.get(sev, "low")
        counts[level] += 1

    error_msg = None
    if issues:
        error_details = []
        for issue in issues:
            error_details.append(f"- {issue.get('rule_name')}: {issue.get('message')} (in {issue.get('range', {}).get('filename', 'unknown')})")
        if error_details:
            error_msg = "TFLint issues found:\n" + "\n".join(error_details)

    return {
        "tool": "tflint",
        "rc": rc,
        "json": data,
        "stderr": err,
        "passed": rc == 0,
        "counts": counts,
        "error_msg": error_msg
    }


def _normalize_checkov_json(raw):
    """
    Checkov may return:
      - dict: single report { "summary": {...}, "results": {...}, ... }
      - list[dict]: multiple reports; we merge summaries and concatenate results lists
    Returns a dict with at least 'summary' and 'results'.
    """
    # Seed structure
    merged = {
        "summary": {
            "passed": 0,
            "failed": 0,
            "skipped": 0,
            "parsing_errors": 0,
            "resource_count": 0,
        },
        "results": {"failed_checks": [], "passed_checks": [], "skipped_checks": []},
    }

    if isinstance(raw, dict):
        # Ensure required keys exist
        s = raw.get("summary") or {}
        for k in merged["summary"].keys():
            merged["summary"][k] = int(s.get(k, 0) or 0)
        r = raw.get("results") or {}
        for key in ("failed_checks", "passed_checks", "skipped_checks"):
            lst = r.get(key)
            if isinstance(lst, list):
                merged["results"][key].extend(lst)
        return merged

    if isinstance(raw, list):
        for item in raw:
            if not isinstance(item, dict):
                continue
            s = item.get("summary") or {}
            for k in merged["summary"].keys():
                merged["summary"][k] += int(s.get(k, 0) or 0)
            r = item.get("results") or {}
            for key in ("failed_checks", "passed_checks", "skipped_checks"):
                lst = r.get(key)
                if isinstance(lst, list):
                    merged["results"][key].extend(lst)
        return merged

    # Fallback for unparsable data
    return merged


def checkov(root: Path, artifacts: Path):
    """Run Checkov, save raw JSON, return normalized summary and score."""
    if shutil.which("checkov") is None:
        return {"tool": "checkov", "skipped": True, "reason": "checkov not installed"}

    # Limit to Terraform to avoid multi-runner outputs, but still normalize just in case.
    cmd = "checkov -d . --framework terraform -o json --quiet --compact --soft-fail"
    rc, out, err = run(cmd, root)

    try:
        raw = json.loads(out) if out else None
    except Exception:
        raw = None

    (artifacts / "checkov.json").write_text(out or "", encoding="utf-8")

    if raw is None:
        return {
            "tool": "checkov",
            "rc": rc,
            "stderr": err,
            "passed": None,
            "reason": "failed to parse output",
            "summary": {},
        }

    data = _normalize_checkov_json(raw)
    summary = data.get("summary") or {}

    failed_checks = int(summary.get("failed", 0) or 0)
    passed_checks = int(summary.get("passed", 0) or 0)
    total_checks = passed_checks + failed_checks

    checkov_score = 10 * (1 - (failed_checks / total_checks)) if total_checks > 0 else 0
    passed = failed_checks == 0  # pass if no failed checks

    error_msg = None
    if failed_checks > 0:
        failed = data.get("results", {}).get("failed_checks", [])
        if failed:
            error_details = []
            for check in failed[:5]:  # Limit to top 5 failures
                error_details.append(f"- {check.get('check_name')}: {check.get('check_id')} in {check.get('file_path', 'unknown')}")
            error_msg = f"Checkov found {failed_checks} issues:\n" + "\n".join(error_details)
            if len(failed) > 5:
                error_msg += f"\n(and {len(failed)-5} more issues)"

    return {
        "tool": "checkov",
        "rc": rc,
        "json": data,          # normalized structure
        "stderr": err,
        "passed": passed,
        "summary": summary,
        "failed_checks": failed_checks,
        "passed_checks": passed_checks,
        "checkov_score": checkov_score,
        "error_msg": error_msg
    }
