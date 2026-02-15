#!/usr/bin/env python3
"""
count_iterative_reviews.py

Counts, per kind, how many projects required an iterative review/fix attempt
(i.e., attempt number != 1), based on the run_dir path in master_metrics.csv.

IMPORTANT:
- Rows with empty/missing run_dir are excluded entirely.

Definition:
- attempt_n is parsed from ".../attempt_<n>/..." inside run_dir
- iterative_review = (attempt_n is not None and attempt_n != 1)
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path
from typing import Any, Optional

import pandas as pd


ATTEMPT_RE = re.compile(r"(?:^|/|\\)attempt_(\d+)(?:/|\\)")


def parse_attempt_n(run_dir: Any) -> Optional[int]:
    if run_dir is None or not isinstance(run_dir, str):
        return None
    s = run_dir.strip()
    if not s:
        return None
    m = ATTEMPT_RE.search(s)
    if not m:
        return None
    try:
        return int(m.group(1))
    except ValueError:
        return None


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", default="./tf_validation/master_metrics.csv")
    ap.add_argument("--out", default="", help="Optional output CSV")
    args = ap.parse_args()

    df = pd.read_csv(Path(args.inp))

    if "kind" not in df.columns or "run_dir" not in df.columns:
        raise ValueError("master_metrics.csv must contain columns: kind, run_dir")

    # Exclude rows with empty/missing run_dir
    df = df[df["run_dir"].notna() & (df["run_dir"].astype(str).str.strip() != "")].copy()

    df["attempt_n"] = df["run_dir"].apply(parse_attempt_n)
    df["iterative_review"] = df["attempt_n"].apply(lambda x: (x is not None and x != 1))

    def share_iterative_among_attempt(g: pd.DataFrame) -> float:
        sub = g[g["attempt_n"].notna()]
        if len(sub) == 0:
            return float("nan")
        return float(sub["iterative_review"].sum()) / float(len(sub))

    summary = (
        df.groupby("kind", dropna=False)
        .agg(
            n_rows=("kind", "size"),  # after filtering empty run_dir
            n_with_attempt=("attempt_n", lambda s: int(s.notna().sum())),
            n_iterative=("iterative_review", lambda s: int(s.sum())),
        )
        .reset_index()
    )

    shares = df.groupby("kind", dropna=False).apply(share_iterative_among_attempt).reset_index(name="share_iterative_among_attempt")
    summary = summary.merge(shares, on="kind", how="left")

    with pd.option_context("display.max_columns", 200, "display.width", 200):
        print(summary.sort_values("kind").to_string(index=False))

    if args.out:
        out_path = Path(args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        summary.to_csv(out_path, index=False)
        print(f"\nWrote: {out_path}")


if __name__ == "__main__":
    main()
