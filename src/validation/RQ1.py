#!/usr/bin/env python3
"""
compute_deployability_passrates.py

Reads ./tf_validation/master_metrics.csv and computes per-kind pass rates for:
  tf_fmt_ok, tf_validate_ok, tf_init_ok, tf_plan_ok, apply_ok, tflint_pass, checkov_pass

Outputs:
- A long-form CSV (one row per kind x metric) if --out is provided
- A console summary table

Notes:
- Supports multiple possible column names in the input (raw extractor vs normalized):
    tf_fmt_ok       -> metrics.tf_fmt_ok | tf_fmt_ok | norm.fmt_ok
    tf_validate_ok  -> metrics.tf_validate_ok | tf_validate_ok | norm.validate_ok
    tf_init_ok      -> metrics.tf_init_ok | tf_init_ok | norm.init_ok
    tf_plan_ok      -> metrics.tf_plan_ok | tf_plan_ok | norm.plan_ok
    apply_ok        -> metrics.apply_ok | apply_ok | norm.apply_ok
    tflint_pass     -> metrics.tflint_pass | tflint_pass | norm.tflint_pass
    checkov_pass    -> metrics.checkov_pass | checkov_pass | norm.checkov_pass
- Pass rates are computed two ways:
    passrate_expected  = passes / expected_n  (default expected_n=113)
    passrate_available = passes / available   (available = non-missing boolean values)
"""

from __future__ import annotations

import argparse
from typing import Any, Dict, List, Optional, Tuple

import pandas as pd


TRUE_SET = {"true", "1", "yes", "y", "ok", "pass", "passed", "success", "succeeded"}
FALSE_SET = {"false", "0", "no", "n", "fail", "failed", "error"}


METRIC_CANDIDATES: Dict[str, List[str]] = {
    "tf_fmt_ok": ["metrics.tf_fmt_ok", "tf_fmt_ok", "norm.fmt_ok"],
    "tf_validate_ok": ["metrics.tf_validate_ok", "tf_validate_ok", "norm.validate_ok"],
    "tf_init_ok": ["metrics.tf_init_ok", "tf_init_ok", "norm.init_ok"],
    "tf_plan_ok": ["metrics.tf_plan_ok", "tf_plan_ok", "norm.plan_ok"],
    "apply_ok": ["metrics.apply_ok", "apply_ok", "norm.apply_ok"],
    "tflint_pass": ["metrics.tflint_pass", "tflint_pass", "norm.tflint_pass"],
    "checkov_pass": ["metrics.checkov_pass", "checkov_pass", "norm.checkov_pass"],
}


def to_bool_or_na(x: Any) -> Optional[bool]:
    if x is None:
        return None
    # pandas NaN
    try:
        if pd.isna(x):
            return None
    except Exception:
        pass

    if isinstance(x, bool):
        return x
    if isinstance(x, (int, float)):
        # treat 0/1 as booleans; other numbers -> bool()
        if x == 0:
            return False
        if x == 1:
            return True
        return bool(x)
    if isinstance(x, str):
        s = x.strip().lower()
        if s in TRUE_SET:
            return True
        if s in FALSE_SET:
            return False
    return None


def pick_existing_column(df: pd.DataFrame, candidates: List[str]) -> Optional[str]:
    for c in candidates:
        if c in df.columns:
            return c
    return None


def compute_passrates(
    df: pd.DataFrame,
    expected_n: int,
    kind_col: str = "kind",
    app_col: str = "app_id",
) -> pd.DataFrame:
    if kind_col not in df.columns:
        raise ValueError(f"Missing required column: {kind_col}")
    if app_col not in df.columns:
        raise ValueError(f"Missing required column: {app_col}")

    # Resolve the actual columns present
    resolved: Dict[str, str] = {}
    for metric, candidates in METRIC_CANDIDATES.items():
        col = pick_existing_column(df, candidates)
        if not col:
            raise ValueError(f"Could not find any column for metric '{metric}'. Tried: {candidates}")
        resolved[metric] = col

    # Normalize booleans into temporary columns
    work = df[[kind_col, app_col] + list(resolved.values())].copy()
    for metric, col in resolved.items():
        work[metric] = work[col].apply(to_bool_or_na)

    # Compute per-kind results in long format
    rows: List[Dict[str, Any]] = []
    for kind, g in work.groupby(kind_col, dropna=False):
        n_rows = int(len(g))
        n_unique_app = int(g[app_col].astype(str).nunique())

        # Composite: all pass (deployable by your gate list)
        # Only counts rows where all metrics are available (non-missing).
        avail_mask = g[list(METRIC_CANDIDATES.keys())].notna().all(axis=1)
        if avail_mask.any():
            all_passes = int((g.loc[avail_mask, list(METRIC_CANDIDATES.keys())] == True).all(axis=1).sum())
            all_available = int(avail_mask.sum())
        else:
            all_passes = 0
            all_available = 0

        for metric in METRIC_CANDIDATES.keys():
            s = g[metric]
            available = int(s.notna().sum())
            passes = int((s == True).sum())

            rows.append(
                {
                    "kind": kind,
                    "metric": metric,
                    "passes": passes,
                    "available": available,
                    "n_rows": n_rows,
                    "n_unique_app_id": n_unique_app,
                    "expected_n": expected_n,
                    "passrate_expected": (passes / expected_n) if expected_n > 0 else None,
                    "passrate_available": (passes / available) if available > 0 else None,
                }
            )

        # Add composite row
        rows.append(
            {
                "kind": kind,
                "metric": "ALL_7_GATES",
                "passes": all_passes,
                "available": all_available,
                "n_rows": n_rows,
                "n_unique_app_id": n_unique_app,
                "expected_n": expected_n,
                "passrate_expected": (all_passes / expected_n) if expected_n > 0 else None,
                "passrate_available": (all_passes / all_available) if all_available > 0 else None,
            }
        )

    out = pd.DataFrame(rows)

    # Optional: delta vs og_eval (if present)
    if (out["kind"] == "og_eval").any():
        base = out[out["kind"] == "og_eval"][["metric", "passrate_expected"]].rename(
            columns={"passrate_expected": "baseline_og_eval_passrate_expected"}
        )
        out = out.merge(base, on="metric", how="left")
        out["delta_vs_og_eval"] = out["passrate_expected"] - out["baseline_og_eval_passrate_expected"]

    return out.sort_values(["metric", "kind"]).reset_index(drop=True)


def print_wide_summary(long_df: pd.DataFrame) -> None:
    # show passrate_expected in a wide table: rows=kind, cols=metric
    pivot = long_df.pivot_table(index="kind", columns="metric", values="passrate_expected", aggfunc="first")
    # keep a readable metric order
    metric_order = list(METRIC_CANDIDATES.keys()) + ["ALL_7_GATES"]
    metric_order = [m for m in metric_order if m in pivot.columns]
    pivot = pivot[metric_order]
    with pd.option_context("display.max_columns", 200, "display.width", 200):
        print(pivot.round(3))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", default="./tf_validation/master_metrics.csv", help="Input master CSV")
    ap.add_argument("--out", default="", help="Optional output CSV (long format)")
    ap.add_argument("--expected-n", type=int, default=113, help="Expected number of app_ids (denominator)")
    args = ap.parse_args()

    df = pd.read_csv(args.inp)
    long_df = compute_passrates(df, expected_n=args.expected_n)

    print_wide_summary(long_df)

    if args.out:
        long_df.to_csv(args.out, index=False)
        print(f"\nWrote long-form passrates to: {args.out}")


if __name__ == "__main__":
    main()
