# normalize.py
from __future__ import annotations

import json
from dataclasses import dataclass
from typing import Any, Callable, Dict, Mapping, Optional, Sequence


# Base columns that CLI always writes (stable schema)
BASE_FIELDS = [
    "app_id",
    "repo_url",          # projected from progress.* (or already present)
    "kind",
    "directory",
    "eval_subpath",
    "attempt_policy",
    "run_policy",
    "status",
    "run_dir",
    "run_dir_name",
]

# Normalized columns (stable schema, prefixed as norm.* in cli.py)
NORMALIZED_FIELDS = [
    # terraform gates
    "init_ok",
    "fmt_ok",
    "validate_ok",
    "plan_ok",
    "apply_ok",
    "graph_generated",

    # plan summary
    "resources_planned_count",

    # tflint
    "tflint_pass",
    "tflint_critical",
    "tflint_high",
    "tflint_medium",
    "tflint_low",
    "tflint_total",

    # checkov
    "checkov_pass",
    "checkov_score",
    "checkov_skipped",
    "checkov_failed",

    # graph
    "graph_nodes",
    "graph_edges",
]


def _coalesce(row: Mapping[str, Any], keys: Sequence[str]) -> Any:
    for k in keys:
        if k in row and row[k] not in (None, ""):
            return row[k]
    return None


def _to_bool(x: Any) -> Optional[bool]:
    if x is None:
        return None
    if isinstance(x, bool):
        return x
    if isinstance(x, (int, float)):
        return bool(x)
    if isinstance(x, str):
        s = x.strip().lower()
        if s in ("true", "1", "yes", "y", "ok", "pass", "passed", "success", "succeeded"):
            return True
        if s in ("false", "0", "no", "n", "fail", "failed", "error"):
            return False
    return None


def _to_int(x: Any) -> Optional[int]:
    if x is None:
        return None
    if isinstance(x, bool):
        return int(x)
    if isinstance(x, int):
        return x
    if isinstance(x, float):
        return int(x)
    if isinstance(x, str):
        s = x.strip()
        try:
            return int(s)
        except ValueError:
            try:
                return int(float(s))
            except ValueError:
                return None
    return None


def _to_float(x: Any) -> Optional[float]:
    if x is None:
        return None
    if isinstance(x, bool):
        return float(int(x))
    if isinstance(x, (int, float)):
        return float(x)
    if isinstance(x, str):
        s = x.strip()
        try:
            return float(s)
        except ValueError:
            return None
    return None


@dataclass(frozen=True)
class FieldSpec:
    out: str
    keys: Sequence[str]
    cast: Callable[[Any], Any]


# Updated mappings for your new metrics.json schema
FIELD_SPECS: Sequence[FieldSpec] = [
    # terraform gates
    FieldSpec("fmt_ok",          ["metrics.tf_fmt_ok"], _to_bool),
    FieldSpec("validate_ok",     ["metrics.tf_validate_ok"], _to_bool),
    FieldSpec("graph_generated", ["metrics.tf_graph_generated"], _to_bool),
    FieldSpec("init_ok",         ["metrics.tf_init_ok"], _to_bool),
    FieldSpec("plan_ok",         ["metrics.tf_plan_ok"], _to_bool),
    FieldSpec("apply_ok",        ["metrics.apply_ok"], _to_bool),

    # plan summary
    FieldSpec("resources_planned_count", ["metrics.resources_planned_count"], _to_int),

    # tflint
    FieldSpec("tflint_pass",     ["metrics.tflint_pass"], _to_bool),
    FieldSpec("tflint_critical", ["metrics.tflint_critical"], _to_int),
    FieldSpec("tflint_high",     ["metrics.tflint_high"], _to_int),
    FieldSpec("tflint_medium",   ["metrics.tflint_medium"], _to_int),
    FieldSpec("tflint_low",      ["metrics.tflint_low"], _to_int),

    # checkov (support both metrics.json or checkov.json summaries)
    FieldSpec("checkov_pass",    ["metrics.checkov_pass"], _to_bool),
    FieldSpec("checkov_score",   ["metrics.checkov_score"], _to_float),
    FieldSpec("checkov_failed",  ["metrics.checkov_failed", "checkov.summary.failed"], _to_int),
    FieldSpec("checkov_skipped", ["metrics.checkov_skipped", "checkov.summary.skipped"], _to_int),

    # graph (support either metrics.json or extractor heuristics)
    FieldSpec("graph_nodes",   ["metrics.graph_nodes", "graph.nodes_heur"], _to_int),
    FieldSpec("graph_edges",   ["metrics.graph_edges", "graph.edges_heur"], _to_int),
]


def project_repo_url(row: Mapping[str, Any]) -> Optional[str]:
    """
    Project repo_url from progress fields.

    Supports:
    - row["repo_url"] already set
    - progress dict flattened: progress.repo_url (recommended)
    - raw progress record flattened: progress.meta.repo_url + progress.status == "source_resolved"
    """
    v = row.get("repo_url")
    if isinstance(v, str) and v.strip():
        return v.strip()

    v = row.get("progress.repo_url")
    if isinstance(v, str) and v.strip():
        return v.strip()

    # if you still store only a single progress event record
    status = row.get("progress.status")
    v = row.get("progress.meta.repo_url")
    if status == "source_resolved" and isinstance(v, str) and v.strip():
        return v.strip()

    # optional alternative shapes if you ever encode status namespaces
    v = row.get("progress.source_resolved.meta.repo_url")
    if isinstance(v, str) and v.strip():
        return v.strip()

    return None


def normalize_row(row: Mapping[str, Any]) -> Dict[str, Any]:
    out: Dict[str, Any] = {k: None for k in NORMALIZED_FIELDS}

    for spec in FIELD_SPECS:
        out[spec.out] = spec.cast(_coalesce(row, spec.keys))

    # derived
    crit = out.get("tflint_critical") or 0
    high = out.get("tflint_high") or 0
    med = out.get("tflint_medium") or 0
    low = out.get("tflint_low") or 0
    if any(v is not None for v in [out.get("tflint_critical"), out.get("tflint_high"), out.get("tflint_medium"), out.get("tflint_low")]):
        out["tflint_total"] = int(crit) + int(high) + int(med) + int(low)
    else:
        out["tflint_total"] = None

    return out


def apply_normalization(row: Dict[str, Any], prefix: str = "norm.") -> Dict[str, Any]:
    # ensure repo_url is available as a base column
    ru = project_repo_url(row)
    if ru and not row.get("repo_url"):
        row["repo_url"] = ru

    n = normalize_row(row)
    row.update({f"{prefix}{k}": v for k, v in n.items()})
    return row


def norm_fieldnames(prefix: str = "norm.") -> list[str]:
    return [f"{prefix}{k}" for k in NORMALIZED_FIELDS]
