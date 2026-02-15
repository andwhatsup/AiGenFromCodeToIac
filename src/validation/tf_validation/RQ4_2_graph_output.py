#!/usr/bin/env python3
"""
plot_graph_similarity_violin.py

Violin plots (one violin per kind) for:
- type_recall_vs_baseline
- type_jaccard_vs_baseline
- edge_type_jaccard_vs_baseline

Also writes per-kind numeric summaries to CSV (default: <outdir>/output.csv).

Uses friendly labels for kinds.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any, Optional

import pandas as pd
import matplotlib.pyplot as plt


KIND_LABELS = {
    "og_eval": "Original",
    "ai_eval_4_1_s_first": "S-Agent GPT 4.1",
    "ai_eval_4_1_s_latest": "S-Agent Iter. GPT 4.1",
    "ai_eval_4_1_m_first": "M-Agent GPT 4.1",
    "ai_eval_4_1_m_latest": "M-Agent Iter. GPT 4.1",
    "ai_eval_5_2_s_first": "S-Agent GPT 5.2",
    "ai_eval_5_2_s_latest": "S-Agent Iter. GPT 5.2",
    "ai_eval_5_2_m_first": "M-Agent GPT 5.2",
    "ai_eval_5_2_m_latest": "M-Agent Iter. GPT 5.2",
}

DEFAULT_KIND_ORDER = [
    "og_eval",
    "ai_eval_4_1_s_first",
    "ai_eval_4_1_s_latest",
    "ai_eval_4_1_m_first",
    "ai_eval_4_1_m_latest",
    "ai_eval_5_2_s_first",
    "ai_eval_5_2_s_latest",
    "ai_eval_5_2_m_first",
    "ai_eval_5_2_m_latest",
]

METRICS = [
    ("type_recall_vs_baseline", "Baseline component-type recall"),
    ("type_jaccard_vs_baseline", "Type Jaccard similarity"),
    ("edge_type_jaccard_vs_baseline", "Edge-type Jaccard similarity"),
]


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


def ordered_kinds(df: pd.DataFrame, include_baseline: bool) -> list[str]:
    present = set(df["kind"].dropna().astype(str).unique().tolist())
    order = [k for k in DEFAULT_KIND_ORDER if k in present]
    extras = sorted([k for k in present if k not in order])
    order = order + extras
    if not include_baseline:
        order = [k for k in order if k != "og_eval"]
    return order


def label_for_kind(kind: str) -> str:
    return KIND_LABELS.get(kind, kind)


def make_violin(
    df: pd.DataFrame,
    metric_col: str,
    title: str,
    out_path: Path,
    kinds: list[str],
) -> None:
    data = []
    labels = []
    for k in kinds:
        vals = df.loc[df["kind"].astype(str) == k, metric_col].dropna().astype(float)
        if len(vals) == 0:
            continue
        data.append(vals.values)
        labels.append(label_for_kind(k))

    if not data:
        raise ValueError(f"No data available for {metric_col}")

    fig_w = max(10, 1.2 * len(labels))
    plt.figure(figsize=(fig_w, 4.8))
    plt.violinplot(data, showmeans=False, showmedians=True, showextrema=True)

    positions = list(range(1, len(labels) + 1))
    plt.xticks(positions, labels, rotation=45, ha="right")

    plt.title(title)
    plt.ylabel(metric_col)
    plt.ylim(0, 1)
    plt.grid(axis="y", linestyle=":", linewidth=0.5)
    plt.tight_layout()

    out_path.parent.mkdir(parents=True, exist_ok=True)
    plt.savefig(out_path, dpi=200)
    plt.close()


def summarize_numbers(df: pd.DataFrame, kinds: list[str]) -> pd.DataFrame:
    """
    Returns a long-form summary table:
      kind, kind_label, metric, metric_label, n, mean, median, p25, p75, min, max
    """
    rows = []
    for k in kinds:
        sub = df[df["kind"].astype(str) == k]
        for metric_col, metric_label in METRICS:
            vals = pd.to_numeric(sub[metric_col], errors="coerce").dropna()
            if vals.empty:
                rows.append(
                    {
                        "kind": k,
                        "kind_label": label_for_kind(k),
                        "metric": metric_col,
                        "metric_label": metric_label,
                        "n": 0,
                        "mean": None,
                        "median": None,
                        "p25": None,
                        "p75": None,
                        "min": None,
                        "max": None,
                    }
                )
                continue

            rows.append(
                {
                    "kind": k,
                    "kind_label": label_for_kind(k),
                    "metric": metric_col,
                    "metric_label": metric_label,
                    "n": int(vals.shape[0]),
                    "mean": float(vals.mean()),
                    "median": float(vals.median()),
                    "p25": float(vals.quantile(0.25)),
                    "p75": float(vals.quantile(0.75)),
                    "min": float(vals.min()),
                    "max": float(vals.max()),
                }
            )

    return pd.DataFrame(rows)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", default="./graph/graph_similarity_long.csv")
    ap.add_argument("--outdir", default="./graph/plots_graph_similarity")
    ap.add_argument("--format", choices=["png", "pdf"], default="png")
    ap.add_argument("--include-baseline", action="store_true", help="Include Original (og_eval) violin")
    ap.add_argument("--outcsv", default="", help="Optional CSV output path (default: <outdir>/output.csv)")
    args = ap.parse_args()

    df = pd.read_csv(Path(args.inp))

    df["has_baseline"] = df["has_baseline"].apply(to_bool)
    df = df[df["has_baseline"] == True].copy()

    for m, _ in METRICS:
        df[m] = pd.to_numeric(df[m], errors="coerce")

    kinds = ordered_kinds(df, include_baseline=args.include_baseline)

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    # Write plots
    for metric_col, pretty in METRICS:
        out_path = outdir / f"violin__{metric_col}.{args.format}"
        make_violin(df, metric_col, pretty, out_path, kinds)

    # Write numeric summaries
    summary_df = summarize_numbers(df, kinds)
    outcsv = Path(args.outcsv) if args.outcsv else (outdir / "output.csv")
    summary_df.to_csv(outcsv, index=False)

    # Optional: also write a wide “one row per kind” table (median + n), next to output.csv
    wide = (
        summary_df.pivot_table(index=["kind", "kind_label"], columns="metric", values="median", aggfunc="first")
        .reset_index()
    )
    wide_n = (
        summary_df.pivot_table(index=["kind", "kind_label"], columns="metric", values="n", aggfunc="first")
        .add_prefix("n__")
        .reset_index()
    )
    wide_out = wide.merge(wide_n, on=["kind", "kind_label"], how="left")
    wide_out.to_csv(outcsv.with_name(outcsv.stem + "_wide" + outcsv.suffix), index=False)

    print(f"Wrote violin plots to: {outdir}")
    print(f"Wrote numeric summary CSV to: {outcsv}")


if __name__ == "__main__":
    main()
