#!/usr/bin/env python3
"""
master_extractor.py (library)

Changes vs your current version:
1) Supports artifacts stored under run_*/** (recursively), not only directly under run_*.
   - For each artifact file, we find the first match in run_dir.rglob(<filename>).
   - Presence flags become true if found anywhere under run_dir.
2) Removes all CLI / CSV writing code (argparse, csv, main, parse_app_ids, write_master_csv).
"""

from __future__ import annotations
import hashlib
import json
import re
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple


# -----------------------------
# 1) Configuration
# -----------------------------

@dataclass(frozen=True)
class KindSpec:
    kind: str
    directory: str
    eval_subpath: str  # e.g. "og_eval" or "ai_basis_eval" or "ai_eval"
    attempt_policy: str  # "none" | "attempt_1" | "attempt_max"
    run_policy: str      # currently only "max" (latest)


KINDS: List[KindSpec] = [
    KindSpec("og_eval",               "gpt5_2v2", "og_eval",       "none",       "max"),
    KindSpec("ai_eval_4_1_s_first",   "gpt4_1_basis", "ai_basis_eval", "attempt_1",  "max"),
    KindSpec("ai_eval_4_1_s_latest",  "gpt4_1_basis", "ai_basis_eval", "attempt_max","max"),
    KindSpec("ai_eval_4_1_m_first",   "gpt4_1",       "ai_eval",       "attempt_1",  "max"),
    KindSpec("ai_eval_4_1_m_latest",  "gpt4_1",       "ai_eval",       "attempt_max","max"),
    KindSpec("ai_eval_5_2_s_first",   "gpt5_2v2", "ai_basis_eval", "attempt_1",  "max"),
    KindSpec("ai_eval_5_2_s_latest",  "gpt5_2v2", "ai_basis_eval", "attempt_max","max"),
    KindSpec("ai_eval_5_2_m_first",   "gpt5_2v2",     "ai_eval",       "attempt_1",  "max"),
    KindSpec("ai_eval_5_2_m_latest",  "gpt5_2v2",     "ai_eval",       "attempt_max","max"),
]

ARTIFACT_FILES = [
    "metrics.json",
    "plan.json",
    "tflint.json",
    "checkov.json",
    "graph.dot",
    "plan_stderr.txt",
    "apply_stderr.txt",
]


# -----------------------------
# 2) Small utilities
# -----------------------------

_RUN_RE = re.compile(r"^run_(\d{8}_\d{6})$")
_ATTEMPT_RE = re.compile(r"^attempt_(\d+)$")


def load_json_safe(path: Path) -> Optional[Any]:
    try:
        with path.open("r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        return None
    except json.JSONDecodeError:
        return {"__parse_error__": f"invalid_json:{path.name}"}


def read_text_safe(path: Path, max_chars: int = 10_000) -> Optional[str]:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
        return text[:max_chars]
    except FileNotFoundError:
        return None


def flatten_json(obj: Any, prefix: str = "", sep: str = ".") -> Dict[str, Any]:
    out: Dict[str, Any] = {}
    if isinstance(obj, dict):
        for k, v in obj.items():
            key = f"{prefix}{sep}{k}" if prefix else str(k)
            out.update(flatten_json(v, key, sep=sep))
    elif isinstance(obj, list):
        out[prefix] = json.dumps(obj, ensure_ascii=False)
    else:
        out[prefix] = obj
    return out


def parse_run_ts(run_dir_name: str) -> Optional[datetime]:
    m = _RUN_RE.match(run_dir_name)
    if not m:
        return None
    return datetime.strptime(m.group(1), "%Y%m%d_%H%M%S")


def pick_latest_run_dir(parent: Path) -> Optional[Path]:
    run_dirs = [p for p in parent.glob("run_*") if p.is_dir()]
    if not run_dirs:
        return None

    scored: List[Tuple[int, str, Path]] = []
    for p in run_dirs:
        ts = parse_run_ts(p.name)
        if ts:
            scored.append((1, ts.isoformat(), p))
        else:
            scored.append((0, p.name, p))

    scored.sort(key=lambda t: (t[0], t[1]), reverse=True)
    return scored[0][2]


def pick_attempt_dir(parent: Path, policy: str) -> Optional[Path]:
    if policy == "none":
        return parent

    attempt_dirs = [p for p in parent.glob("attempt_*") if p.is_dir()]
    if not attempt_dirs:
        return None

    if policy == "attempt_1":
        p = parent / "attempt_1"
        return p if p.is_dir() else None

    if policy == "attempt_max":
        best_n = -1
        best_p: Optional[Path] = None
        for p in attempt_dirs:
            m = _ATTEMPT_RE.match(p.name)
            if not m:
                continue
            n = int(m.group(1))
            if n > best_n:
                best_n = n
                best_p = p
        return best_p

    raise ValueError(f"Unknown attempt policy: {policy}")


def count_dot_nodes_edges(dot_text: str) -> Dict[str, Any]:
    lines = [ln.strip() for ln in dot_text.splitlines() if ln.strip() and not ln.strip().startswith("//")]
    edges = sum(ln.count("->") for ln in lines)

    node_lines = 0
    for ln in lines:
        if ln.startswith(("digraph", "graph", "node ", "edge ")):
            continue
        if "->" in ln:
            continue
        if "[" in ln and "]" in ln:
            node_lines += 1

    return {"graph.nodes_heur": node_lines, "graph.edges_heur": edges}


# -----------------------------
# 3) Resolve paths per (app_id, kind)
# -----------------------------

def resolve_run_dir(results_root: Path, spec: KindSpec, app_id: str) -> Optional[Path]:
    log_root = results_root / spec.directory / "log"
    per_app_root = log_root / app_id / spec.eval_subpath

    if spec.attempt_policy == "none":
        return pick_latest_run_dir(per_app_root)

    attempt_dir = pick_attempt_dir(per_app_root, spec.attempt_policy)
    if not attempt_dir:
        return None
    return pick_latest_run_dir(attempt_dir)


# master_extractor.py

import json
from pathlib import Path
from typing import Any, Dict, Optional


def extract_progress_map(results_root: Path, directory: str) -> Dict[str, Any]:
    """
    Reads ./01_RESULTS/<directory>/log/progress.jsonl (preferred) or progress.json and returns:
      { "<app_id>": {"repo_url": "...", "ts": "..."} }

    Rule: take the latest record where status == "source_resolved" and meta.repo_url exists.
    """
    log_dir = results_root / directory / "log"
    path_jsonl = log_dir / "progress.jsonl"
    path_json = log_dir / "progress.json"

    records: list[dict] = []

    if path_jsonl.exists():
        # JSONL: one JSON object per line
        try:
            for ln in path_jsonl.read_text(encoding="utf-8").splitlines():
                ln = ln.strip()
                if not ln:
                    continue
                obj = json.loads(ln)
                if isinstance(obj, dict):
                    records.append(obj)
        except (OSError, json.JSONDecodeError):
            return {}
    else:
        # JSON: dict or list
        data = load_json_safe(path_json)
        if data is None:
            return {}
        if isinstance(data, dict):
            # if this is already keyed by app_id, keep as-is
            # but also try to normalize to the {app_id: {...}} shape
            # (if it isn't already, you can remove this branch)
            return data
        if isinstance(data, list):
            records = [r for r in data if isinstance(r, dict)]
        else:
            return {}

    out: Dict[str, Any] = {}
    for rec in records:
        if "app_id" not in rec:
            continue
        app_id = str(rec["app_id"])

        if rec.get("status") != "source_resolved":
            continue

        meta = rec.get("meta")
        repo_url = meta.get("repo_url") if isinstance(meta, dict) else None
        if not (isinstance(repo_url, str) and repo_url.strip()):
            continue

        ts = rec.get("ts")
        prev = out.get(app_id)
        prev_ts = prev.get("ts") if isinstance(prev, dict) else None

        # ISO timestamps sort lexicographically; if ts missing, just take it.
        if prev is None or (isinstance(ts, str) and (not isinstance(prev_ts, str) or ts > prev_ts)):
            out[app_id] = {"repo_url": repo_url.strip(), "ts": ts, "status": "source_resolved"}

    return out



# -----------------------------
# 4) Artifact lookup (recursive under run_dir)
# -----------------------------

def _find_under_run(run_dir: Path, filename: str) -> Optional[Path]:
    """
    Find a file anywhere under run_dir/**/filename.
    - Returns first match in deterministic order (sorted by path).
    - If multiple exist, prefer the shallowest path, then lexicographic.
    """
    matches = [p for p in run_dir.rglob(filename) if p.is_file()]
    if not matches:
        return None

    def score(p: Path) -> Tuple[int, str]:
        # depth relative to run_dir, then path string
        rel = p.relative_to(run_dir)
        depth = len(rel.parts)
        return (depth, str(rel))

    matches.sort(key=score)
    return matches[0]

def extract_plan_summary(plan: Any) -> Dict[str, Any]:
    if not isinstance(plan, dict):
        return {}

    def _len_list(x: Any) -> Optional[int]:
        return len(x) if isinstance(x, list) else None

    out: Dict[str, Any] = {}
    out["plan.format_version"] = plan.get("format_version")
    out["plan.terraform_version"] = plan.get("terraform_version")
    out["plan.timestamp"] = plan.get("timestamp")
    out["plan.applyable"] = plan.get("applyable")
    out["plan.complete"] = plan.get("complete")
    out["plan.errored"] = plan.get("errored")

    out["plan.resource_changes_count"] = _len_list(plan.get("resource_changes"))
    out["plan.output_changes_count"] = _len_list(list(plan.get("output_changes", {}).keys())) if isinstance(plan.get("output_changes"), dict) else None

    # planned_values.root_module.resources count (best-effort)
    pv = plan.get("planned_values")
    if isinstance(pv, dict):
        rm = pv.get("root_module")
        if isinstance(rm, dict):
            out["plan.planned_root_resources_count"] = _len_list(rm.get("resources"))

    return out

def extract_checkov_summary(obj: Any) -> Dict[str, Any]:
    """
    Works with common Checkov output shapes. Best-effort.
    Produces only scalar counts + a few identifiers.
    """
    if not isinstance(obj, dict):
        return {}

    out: Dict[str, Any] = {}

    # Some outputs have summary at top-level
    summary = obj.get("summary")
    if isinstance(summary, dict):
        for k in ("passed", "failed", "skipped", "parsing_errors"):
            if k in summary:
                out[f"checkov.summary.{k}"] = summary.get(k)

    # Common lists
    # (Often: results -> failed_checks / passed_checks / skipped_checks)
    results = obj.get("results")
    if isinstance(results, dict):
        for k in ("failed_checks", "passed_checks", "skipped_checks", "parsing_errors"):
            v = results.get(k)
            if isinstance(v, list):
                out[f"checkov.results.{k}_count"] = len(v)

        # If summary missing, derive failed from list length
        if "checkov.summary.failed" not in out and isinstance(results.get("failed_checks"), list):
            out["checkov.summary.failed"] = len(results["failed_checks"])
        if "checkov.summary.passed" not in out and isinstance(results.get("passed_checks"), list):
            out["checkov.summary.passed"] = len(results["passed_checks"])
        if "checkov.summary.skipped" not in out and isinstance(results.get("skipped_checks"), list):
            out["checkov.summary.skipped"] = len(results["skipped_checks"])

    # Sometimes there is "check_type" / "framework" metadata
    for k in ("check_type", "framework", "version"):
        if k in obj and isinstance(obj.get(k), (str, int, float, bool)):
            out[f"checkov.{k}"] = obj.get(k)

    return out

def extract_artifacts(run_dir: Path) -> Dict[str, Any]:
    row: Dict[str, Any] = {
        "run_dir": str(run_dir),
        "run_dir_name": run_dir.name,
    }

    # presence flags + resolved paths
    resolved: Dict[str, Optional[Path]] = {}
    for fn in ARTIFACT_FILES:
        p = _find_under_run(run_dir, fn)
        resolved[fn] = p
        row[f"has.{fn}"] = p is not None
        if p is not None:
            row[f"path.{fn}"] = str(p)

    # metrics.json
    p = resolved["metrics.json"]
    metrics = load_json_safe(p) if p else None
    if metrics is not None:
        row.update({f"metrics.{k}": v for k, v in flatten_json(metrics).items()})

    # plan.json (summary only)
    p = resolved["plan.json"]
    plan = load_json_safe(p) if p else None
    if plan is not None:
        row.update(extract_plan_summary(plan))

    # tflint.json
    p = resolved["tflint.json"]
    tflint = load_json_safe(p) if p else None
    if isinstance(tflint, dict):
        issues = tflint.get("issues") or []
        errors = tflint.get("errors") or []

        # store raw lists as JSON strings (so CSV stays 1-cell-per-row)
        row["tflint.issues"] = json.dumps(issues, ensure_ascii=False)
        row["tflint.errors"] = json.dumps(errors, ensure_ascii=False)

        # simple counts
        row["tflint.issue_count"] = len(issues)
        row["tflint.error_count"] = len(errors)

        # severity counts (ERROR/WARNING/INFO -> high/medium/low)
        sev_map = {"ERROR": "high", "WARNING": "medium", "INFO": "low"}
        counts = {"high": 0, "medium": 0, "low": 0}

        for it in issues:
            rule = it.get("rule") if isinstance(it, dict) else None
            sev = None
            if isinstance(rule, dict):
                sev = rule.get("severity")
            if sev is None and isinstance(it, dict):
                sev = it.get("severity")  # fallback if flattened

            bucket = sev_map.get(str(sev).strip().upper())
            if bucket:
                counts[bucket] += 1

        row["tflint.low"] = counts["low"]
        row["tflint.medium"] = counts["medium"]
        row["tflint.high"] = counts["high"]

        # pass flag (strict): pass only if there are no issues and no errors
        row["tflint.pass"] = (len(issues) == 0 and len(errors) == 0)

        # optional: keep flattening for non-list metadata only (avoids exploding issues into columns)
        meta = {k: v for k, v in tflint.items() if k not in ("issues", "errors")}
        row.update({f"tflint.{k}": v for k, v in flatten_json(meta).items()})


    # checkov.json (summary only)
    p = resolved["checkov.json"]
    checkov = load_json_safe(p) if p else None
    if checkov is not None:
        row.update(extract_checkov_summary(checkov))

    # graph.dot
    p = resolved["graph.dot"]
    if p:
        dot_bytes = p.read_bytes()
        row["graph.bytes"] = len(dot_bytes)
        row["graph.sha256"] = hashlib.sha256(dot_bytes).hexdigest()

        # optional: cheap diagnostics
        try:
            dot_text = dot_bytes.decode("utf-8", errors="replace")
            row["graph.lines"] = dot_text.count("\n") + 1 if dot_text else 0
            row.update(count_dot_nodes_edges(dot_text))  # keeps nodes_heur/edges_heur
        except Exception:
            pass

    # stderr heads
    p = resolved["plan_stderr.txt"]
    plan_err = read_text_safe(p, max_chars=4000) if p else None
    if plan_err is not None:
        row["plan_stderr.head"] = plan_err

    p = resolved["apply_stderr.txt"]
    apply_err = read_text_safe(p, max_chars=4000) if p else None
    if apply_err is not None:
        row["apply_stderr.head"] = apply_err

    return row


def build_row(
    results_root: Path,
    spec: KindSpec,
    app_id: str,
    progress_index: Dict[str, Any],
) -> Dict[str, Any]:
    base: Dict[str, Any] = {
        "app_id": app_id,
        "kind": spec.kind,
        "directory": spec.directory,
        "eval_subpath": spec.eval_subpath,
        "attempt_policy": spec.attempt_policy,
        "run_policy": spec.run_policy,
    }

    # prog = progress_index.get(app_id)
    # if isinstance(prog, dict):
    #     if "repo_url" in prog and isinstance(prog["repo_url"], str):
    #         base["repo_url"] = prog["repo_url"]
    #     base.update({f"progress.{k}": v for k, v in flatten_json(prog).items()})

    run_dir = resolve_run_dir(results_root, spec, app_id)
    if not run_dir:
        base["status"] = "missing_run_dir"
        return base

    base["status"] = "ok"
    base.update(extract_artifacts(run_dir))
    return base
