#!/usr/bin/env python3
"""
compute_graph_size_medians_by_kind.py

Per kind, computes medians for graph size metrics (type-level):
- median_nodes  = median(kind_type_count)
- median_edges  = median(kind_edge_type_count)
- median_edges_per_node = median(kind_edges / kind_nodes)

Comparative to baseline (og_eval, per app_id):
- median_node_ratio_vs_baseline = median(kind_nodes / baseline_nodes)
- median_edge_ratio_vs_baseline = median(kind_edges / baseline_edges)

Input default:  ./graph/graph_similarity_long.csv
Output default: ./graph/graph_size_medians_by_kind.csv
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any, Optional

import pandas as pd


def to_bool(x: Any) -> Optional[bool]:
    if x is None:
        return None
    try:
        if pd.isna(x):
            return None
    except Exception:
        pass
    if isinstance(x, bool):
        return x
    if isinstance(x, (int, float)):
        return bool(x)
    if isinstance(x, str):
        s = x.strip().lower()
        if s in ("true", "1", "yes", "y"):
            return True
        if s in ("false", "0", "no", "n"):
            return False
    return None


def safe_median(s: pd.Series) -> Optional[float]:
    s2 = s.dropna()
    return float(s2.median()) if not s2.empty else None


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", default="./graph/graph_similarity_long.csv")
    ap.add_argument("--out", default="./graph/graph_size_medians_by_kind.csv")
    ap.add_argument("--include-baseline-kind", action="store_true", help="Include og_eval in the summary")
    args = ap.parse_args()

    df = pd.read_csv(args.inp)

    required = [
        "kind",
        "has_baseline",
        "baseline_type_count",
        "kind_type_count",
        "baseline_edge_type_count",
        "kind_edge_type_count",
    ]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    df["has_baseline"] = df["has_baseline"].apply(to_bool)

    for c in required[2:]:
        df[c] = pd.to_numeric(df[c], errors="coerce")

    if not args.include_baseline_kind:
        df = df[df["kind"] != "og_eval"].copy()

    # Only rows where baseline exists
    df = df[df["has_baseline"] == True].copy()

    # Derived per-row metrics
    df["edges_per_node"] = df["kind_edge_type_count"] / df["kind_type_count"]
    df.loc[df["kind_type_count"] <= 0, "edges_per_node"] = pd.NA

    df["node_ratio_vs_baseline"] = df["kind_type_count"] / df["baseline_type_count"]
    df.loc[df["baseline_type_count"] <= 0, "node_ratio_vs_baseline"] = pd.NA

    df["edge_ratio_vs_baseline"] = df["kind_edge_type_count"] / df["baseline_edge_type_count"]
    df.loc[df["baseline_edge_type_count"] <= 0, "edge_ratio_vs_baseline"] = pd.NA

    rows = []
    for kind, g in df.groupby("kind", dropna=False):
        rows.append(
            {
                "kind": kind,
                "n_rows": int(len(g)),

                "n_nodes_available": int(g["kind_type_count"].notna().sum()),
                "median_nodes": safe_median(g["kind_type_count"]),

                "n_edges_available": int(g["kind_edge_type_count"].notna().sum()),
                "median_edges": safe_median(g["kind_edge_type_count"]),

                "n_edges_per_node_available": int(g["edges_per_node"].notna().sum()),
                "median_edges_per_node": safe_median(g["edges_per_node"]),

                "n_node_ratio_available": int(g["node_ratio_vs_baseline"].notna().sum()),
                "median_node_ratio_vs_baseline": safe_median(g["node_ratio_vs_baseline"]),

                "n_edge_ratio_available": int(g["edge_ratio_vs_baseline"].notna().sum()),
                "median_edge_ratio_vs_baseline": safe_median(g["edge_ratio_vs_baseline"]),
            }
        )

    out_df = pd.DataFrame(rows).sort_values("kind").reset_index(drop=True)

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_df.to_csv(out_path, index=False)

    with pd.option_context("display.max_columns", 200, "display.width", 220):
        print(out_df.round(3).to_string(index=False))

    print(f"\nWrote: {out_path}")


if __name__ == "__main__":
    main()
