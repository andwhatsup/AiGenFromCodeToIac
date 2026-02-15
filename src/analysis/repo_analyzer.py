# analysis/repo_analyzer.py
from __future__ import annotations

from pathlib import Path
import json
from typing import Dict, List, Set
import re

from analysis.terraform_scanner import find_terraform_roots, scan_root
from analysis.localstack_checker import check_localstack_compatibility
from analysis.tfvars_builder import generate_tfvars_file, load_existing_var_values


def _rel(repo_dir: Path, p: Path) -> str:
    return str(Path(p).resolve().relative_to(repo_dir))


def _is_ancestor(a: Path, b: Path) -> bool:
    # True if a is a parent directory of b (and not equal)
    try:
        rel = Path(b).resolve().relative_to(Path(a).resolve())
        return rel != Path(".")
    except Exception:
        return False

def _detect_hyphen_vars_in_root(root: Path) -> list[str]:
    """
    Return variable names declared with hyphens (Terraform 0.11-era, invalid in 0.12+).
    We only look at declarations, not usages.
    """
    rx = re.compile(r'variable\s+"([^"]*-[^"]*)"', re.IGNORECASE)
    bad: set[str] = set()
    for tf in list(root.glob("*.tf")) + list(root.glob("*.tf.json")):
        try:
            txt = tf.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for m in rx.finditer(txt):
            bad.add(m.group(1))
    return sorted(bad)

async def analyze_repo(repo_dir: Path,analysis_dir: Path) -> bool:
    repo_dir = Path(repo_dir).resolve()

    roots: List[Path] = find_terraform_roots(repo_dir)

    # Aggregates for gate.json
    summaries: List[Dict] = []
    services_report: Dict[str, Dict] = {}
    varfiles_created: Dict[str, bool] = {}
    filtered_out: Dict[str, List[str]] = {}

    # First pass: scan, attempt to fill required vars, classify services
    candidates: List[Path] = []
    root_meta: Dict[str, Dict] = {}

    for root in roots:
        summary = scan_root(root)
        summaries.append(summary)

        rel = _rel(repo_dir, root)
        reasons: List[str] = []

        # 1) Must have at least one resource/data type
        resource_type_counts: Dict[str, int] = summary.get("resource_type_counts", {}) or {}
        has_resources = sum(resource_type_counts.values()) > 0
        if not has_resources:
            reasons.append("no_resources")

        # 2) Ensure required vars are provided; generate localstack.auto.tfvars.json if needed
        req_meta = summary.get("variables", {}) or {}
        _, provided, created = generate_tfvars_file(root, req_meta, app_hint=root.name)
        varfiles_created[rel] = bool(created)

        # Recompute missing after generation by looking at existing varfiles
        existing_vals = load_existing_var_values(root)
        required_names = [k for k, v in req_meta.items() if not v.get("has_default")]
        still_missing = [k for k in required_names if k not in existing_vals and k not in provided]
        if still_missing:
            reasons.append("missing_required_vars")

        bad_hyphen_vars = _detect_hyphen_vars_in_root(root)
        if bad_hyphen_vars:
            reasons.append("legacy_hcl_hyphen_vars")

        # 3) LocalStack deployability
        resource_types: Set[str] = set(resource_type_counts.keys())
        deployable, report = check_localstack_compatibility(resource_types, require_full=False)
        services_report[rel] = report
        if not deployable:
            reasons.append("not_deployable_localstack")

        # Collect meta and decide candidacy
        root_meta[rel] = {
            "path": str(root),
            "has_resources": has_resources,
            "still_missing_vars": still_missing,
            "deployable": deployable,
        }

        if reasons:
            filtered_out[rel] = reasons
        else:
            candidates.append(root)

    # 4) Keep only leaf roots among candidates to avoid evaluating parents and children both
    candidates_sorted = sorted(candidates, key=lambda p: (len(p.resolve().parts), str(p)))
    leaf_only: List[Path] = []
    for r in candidates_sorted:
        if any(_is_ancestor(r, o) for o in candidates_sorted if o != r):
            # r is a parent of at least one other candidate → drop as non-leaf
            filtered_out[_rel(repo_dir, r)] = filtered_out.get(_rel(repo_dir, r), []) + ["non_leaf"]
            continue
        leaf_only.append(r)

    recommended = [_rel(repo_dir, r) for r in leaf_only]

    gate = {
        "roots_scanned": [ _rel(repo_dir, r) for r in roots ],
        "recommended_roots": recommended,
        "varfiles_created": varfiles_created,
        "services_report": services_report,
        "filtered_out": filtered_out,
        "scanner_summaries": summaries,  # keep for debugging; remove if too verbose
    }
    (analysis_dir / "gate.json").write_text(json.dumps(gate, indent=2), encoding="utf-8")

    return len(recommended) > 0
