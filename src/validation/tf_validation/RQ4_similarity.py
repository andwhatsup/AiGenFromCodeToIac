#!/usr/bin/env python3
"""
compute_graph_similarity_rq2.py

Computes (per app_id, per kind) graph similarity against og_eval baseline using DOT graphs.

Outputs these metrics (og_eval as baseline):
- baseline component-type recall: |T_kind ∩ T_og| / |T_og|
- type Jaccard:                 |T_kind ∩ T_og| / |T_kind ∪ T_og|
- edge overlap at type-level:   |E_kind ∩ E_og| / |E_kind ∪ E_og|
  where E_* are directed edges after mapping node labels -> node types.

Input:  ./tf_validation/master_metrics.csv
Output: ./tf_validation/graph_similarity_long.csv (default)

DOT path resolution:
- Prefer column: "path.graph.dot" (from your extractor)
- Fallback: search graph.dot under run_dir/**

Node type extraction (Terraform address -> type):
- strips leading module paths (module.<name> repeated)
- if "data" resource: type = "data.<data_source_type>" (e.g., data.aws_subnets)
- else: type = "<resource_type>" (e.g., aws_eks_cluster)

Run:
  python compute_graph_similarity_rq2.py \
    --in ./tf_validation/master_metrics.csv \
    --out ./tf_validation/graph_similarity_long.csv
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Dict, Optional, Set, Tuple

import pandas as pd


# ----------------------------
# DOT parsing
# ----------------------------

_NODE_RE = re.compile(
    r'^\s*"(?P<id>[^"]+)"\s*\[(?P<attrs>.*?)\]\s*;\s*$'
)
_LABEL_RE = re.compile(
    r'label\s*=\s*"(?P<label>[^"]+)"'
)
_EDGE_RE = re.compile(
    r'^\s*"(?P<src>[^"]+)"\s*->\s*"(?P<dst>[^"]+)"\s*;\s*$'
)


def parse_dot(dot_text: str) -> Tuple[Dict[str, str], Set[Tuple[str, str]]]:
    """
    Returns:
      node_id -> label (fallback to id if label missing)
      edges as (src_id, dst_id)
    """
    node_labels: Dict[str, str] = {}
    edges: Set[Tuple[str, str]] = set()

    for line in dot_text.splitlines():
        m = _NODE_RE.match(line)
        if m:
            nid = m.group("id")
            attrs = m.group("attrs")
            lm = _LABEL_RE.search(attrs)
            label = lm.group("label") if lm else nid
            node_labels[nid] = label
            continue

        m = _EDGE_RE.match(line)
        if m:
            edges.add((m.group("src"), m.group("dst")))

    return node_labels, edges


def tf_address_to_type(label: str) -> Optional[str]:
    """
    Terraform address -> component type.

    Examples:
      aws_eks_cluster.example                -> aws_eks_cluster
      data.aws_subnets.public                -> data.aws_subnets
      module.net.aws_vpc.default             -> aws_vpc
      module.a.module.b.data.aws_vpc.default -> data.aws_vpc
    """
    if not isinstance(label, str) or not label.strip():
        return None

    parts = label.strip().split(".")
    i = 0

    # strip module.<name> chains
    while i + 1 < len(parts) and parts[i] == "module":
        i += 2

    if i >= len(parts):
        return None

    if parts[i] == "data":
        if i + 1 < len(parts):
            return f"data.{parts[i+1]}"
        return None

    return parts[i]


def types_and_type_edges_from_dot(dot_path: Path) -> Tuple[Set[str], Set[Tuple[str, str]]]:
    txt = dot_path.read_text(encoding="utf-8", errors="replace")
    node_labels, edges = parse_dot(txt)

    # node types
    node_type: Dict[str, Optional[str]] = {}
    types: Set[str] = set()
    for nid, lbl in node_labels.items():
        t = tf_address_to_type(lbl)
        node_type[nid] = t
        if t:
            types.add(t)

    # edge types (directed)
    edge_types: Set[Tuple[str, str]] = set()
    for src, dst in edges:
        st = node_type.get(src) or tf_address_to_type(src)
        dt = node_type.get(dst) or tf_address_to_type(dst)
        if st and dt:
            edge_types.add((st, dt))

    return types, edge_types


# ----------------------------
# CSV helpers
# ----------------------------

def pick_existing_column(df: pd.DataFrame, candidates: list[str]) -> Optional[str]:
    for c in candidates:
        if c in df.columns:
            return c
    return None


def find_graph_dot_path(row: pd.Series, path_col: Optional[str], run_dir_col: Optional[str]) -> Optional[Path]:
    # 1) direct resolved path from extractor
    if path_col:
        v = row.get(path_col)
        if isinstance(v, str) and v.strip():
            p = Path(v)
            if p.exists():
                return p

    # 2) fallback: search under run_dir/**
    if run_dir_col:
        v = row.get(run_dir_col)
        if isinstance(v, str) and v.strip():
            rd = Path(v)
            if rd.exists() and rd.is_dir():
                matches = sorted([p for p in rd.rglob("graph.dot") if p.is_file()], key=lambda p: (len(p.parts), str(p)))
                if matches:
                    return matches[0]

    return None


def jaccard(a: Set, b: Set) -> Optional[float]:
    if not a and not b:
        return 1.0
    u = a | b
    if not u:
        return None
    return len(a & b) / len(u)


def recall_against_baseline(candidate: Set, baseline: Set) -> Optional[float]:
    if not baseline:
        return None
    return len(candidate & baseline) / len(baseline)


# ----------------------------
# Main computation
# ----------------------------

def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", default="./master_metrics.csv")
    ap.add_argument("--out", default="./graph/graph_similarity_long.csv")
    ap.add_argument("--baseline-kind", default="og_eval")
    args = ap.parse_args()

    df = pd.read_csv(args.inp)

    if "app_id" not in df.columns or "kind" not in df.columns:
        raise ValueError("Input CSV must contain columns: app_id, kind")

    path_col = pick_existing_column(df, ["path.graph.dot", "graph_dot_path", "path_graph_dot"])
    run_dir_col = pick_existing_column(df, ["run_dir"])

    # Cache parsed (types, edge_types) by dot path
    cache: Dict[str, Tuple[Set[str], Set[Tuple[str, str]]]] = {}

    def get_sets(dot_path: Path) -> Tuple[Set[str], Set[Tuple[str, str]]]:
        key = str(dot_path.resolve())
        if key not in cache:
            cache[key] = types_and_type_edges_from_dot(dot_path)
        return cache[key]

    # Build baseline lookup per app_id
    baseline_types: Dict[str, Set[str]] = {}
    baseline_edges: Dict[str, Set[Tuple[str, str]]] = {}

    base_df = df[df["kind"] == args.baseline_kind]
    for _, r in base_df.iterrows():
        app_id = str(r["app_id"])
        p = find_graph_dot_path(r, path_col, run_dir_col)
        if not p:
            continue
        tset, eset = get_sets(p)
        baseline_types[app_id] = tset
        baseline_edges[app_id] = eset

    # Compute per-row similarities vs baseline
    out_rows = []
    for _, r in df.iterrows():
        app_id = str(r["app_id"])
        kind = str(r["kind"])

        bt = baseline_types.get(app_id)
        be = baseline_edges.get(app_id)
        if bt is None or be is None:
            out_rows.append(
                {
                    "app_id": app_id,
                    "kind": kind,
                    "baseline_kind": args.baseline_kind,
                    "has_baseline": False,
                    "type_recall_vs_baseline": None,
                    "type_jaccard_vs_baseline": None,
                    "edge_type_jaccard_vs_baseline": None,
                    "baseline_type_count": None,
                    "kind_type_count": None,
                    "baseline_edge_type_count": None,
                    "kind_edge_type_count": None,
                }
            )
            continue

        p = find_graph_dot_path(r, path_col, run_dir_col)
        if not p:
            out_rows.append(
                {
                    "app_id": app_id,
                    "kind": kind,
                    "baseline_kind": args.baseline_kind,
                    "has_baseline": True,
                    "type_recall_vs_baseline": None,
                    "type_jaccard_vs_baseline": None,
                    "edge_type_jaccard_vs_baseline": None,
                    "baseline_type_count": len(bt),
                    "kind_type_count": None,
                    "baseline_edge_type_count": len(be),
                    "kind_edge_type_count": None,
                }
            )
            continue

        kt, ke = get_sets(p)

        out_rows.append(
            {
                "app_id": app_id,
                "kind": kind,
                "baseline_kind": args.baseline_kind,
                "has_baseline": True,
                # requested metrics
                "type_recall_vs_baseline": recall_against_baseline(kt, bt),
                "type_jaccard_vs_baseline": jaccard(kt, bt),
                "edge_type_jaccard_vs_baseline": jaccard(ke, be),
                # helpful context
                "baseline_type_count": len(bt),
                "kind_type_count": len(kt),
                "baseline_edge_type_count": len(be),
                "kind_edge_type_count": len(ke),
            }
        )

    out_df = pd.DataFrame(out_rows)
    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_df.to_csv(out_path, index=False)
    print(f"Wrote: {out_path}")


if __name__ == "__main__":
    main()
