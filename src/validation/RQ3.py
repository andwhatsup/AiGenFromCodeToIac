#!/usr/bin/env python3
"""
RQ3.py

Per kind, outputs:
- tf_linter        = mean pass rate (tflint_pass)
- tf_lint_low      = median low issues per project
- tf_lint_medium   = median medium issues per project
- tf_lint_high     = median high issues per project
- checkov_pass     = mean pass rate (checkov_pass)
- checkov_failed   = median failed checks per project
- checkov_count    = median total evaluated checks per project (passed+failed)

Additionally prints (per kind):
- repos_total            = number of repos/projects in that kind (unique id if available)
- tf_lint_medium_repos   = number of repos/projects with tf_lint_medium > 0

Input: ./tf_validation/master_metrics.csv
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import pandas as pd


TRUE_SET = {"true", "1", "yes", "y", "ok", "pass", "passed", "success", "succeeded"}
FALSE_SET = {"false", "0", "no", "n", "fail", "failed", "error"}


def to_bool_or_na(x: Any) -> Optional[bool]:
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


def to_int_or_na(x: Any) -> Optional[int]:
    if x is None:
        return None
    try:
        if pd.isna(x):
            return None
    except Exception:
        pass
    if isinstance(x, bool):
        return int(x)
    if isinstance(x, int):
        return x
    if isinstance(x, float):
        return int(x)
    if isinstance(x, str):
        s = x.strip()
        if not s:
            return None
        try:
            return int(s)
        except ValueError:
            try:
                return int(float(s))
            except ValueError:
                return None
    return None


def pick_existing_column(df: pd.DataFrame, candidates: List[str]) -> str:
    for c in candidates:
        if c in df.columns:
            return c
    raise ValueError(f"None of the candidate columns exist: {candidates}")


def pick_existing_column_or_none(df: pd.DataFrame, candidates: List[str]) -> Optional[str]:
    for c in candidates:
        if c in df.columns:
            return c
    return None


def resolve_artifact_path(csv_path: Path, p: str) -> Path:
    pp = Path(p)
    if pp.is_absolute():
        return pp
    return (csv_path.parent / pp).resolve()


def parse_tflint_counts_from_json_file(p: Path) -> Optional[Dict[str, int]]:
    """
    Reads a tflint JSON file and returns counts mapped to:
      ERROR   -> high
      WARNING -> medium
      NOTICE  -> low
    (INFO is treated as low as a fallback)

    Supports common tflint JSON structure where severity is in issue["rule"]["severity"].
    """
    try:
        raw = p.read_text(encoding="utf-8")
    except Exception:
        return None
    if not raw.strip():
        return None

    try:
        data = json.loads(raw)
    except Exception:
        return None

    issues = []
    if isinstance(data, dict) and isinstance(data.get("issues"), list):
        issues = data["issues"]
    elif isinstance(data, list):
        issues = data

    sev_map = {
        "ERROR": "high",
        "WARNING": "medium",
        "NOTICE": "low",
        "INFO": "low",
    }

    counts = {"critical": 0, "high": 0, "medium": 0, "low": 0}
    for it in issues or []:
        if not isinstance(it, dict):
            continue
        sev = it.get("severity") or (it.get("rule") or {}).get("severity") or ""
        level = sev_map.get(str(sev).upper(), "low")
        counts[level] += 1

    return counts


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", default="./tf_validation/master_metrics.csv")
    ap.add_argument("--out", default="", help="Optional CSV output with per-kind stats")
    args = ap.parse_args()

    csv_path = Path(args.inp).resolve()
    df = pd.read_csv(csv_path)
    if "kind" not in df.columns:
        raise ValueError("Missing required column: kind")

    # project/repo identifier (used for "of 113 repos" style counts)
    repo_id_col = pick_existing_column_or_none(df, ["app_id", "repo_id", "project_id", "id"])

    # Optional: recompute tflint severities from stored JSON artifact
    tflint_json_col = pick_existing_column_or_none(
        df,
        [
            "path.tflint.json",
            "paths.tflint.json",
            "metrics.path.tflint.json",
            "artifacts.tflint.json",
            "tflint.json.path",
            "tflint_json_path",
        ],
    )

    cols = {
        "tflint_pass": pick_existing_column(df, ["metrics.tflint_pass", "norm.tflint_pass", "tflint_pass"]),
        "checkov_pass": pick_existing_column(df, ["metrics.checkov_pass", "norm.checkov_pass", "checkov_pass"]),
        "checkov_failed": pick_existing_column(
            df,
            [
                "checkov.summary.failed",
                "checkov.results.failed_checks_count",
                "checkov_failed",
                "norm.checkov_failed",
                "metrics.checkov_failed",
            ],
        ),
        "checkov_passed": pick_existing_column(
            df,
            [
                "checkov.summary.passed",
                "checkov.results.passed_checks_count",
                "checkov.passed_checks_count",
                "norm.checkov_passed_checks_count",
            ],
        ),
    }

    base_cols = ["kind", cols["tflint_pass"], cols["checkov_pass"], cols["checkov_failed"], cols["checkov_passed"]]
    if repo_id_col:
        base_cols.append(repo_id_col)
    if tflint_json_col:
        base_cols.append(tflint_json_col)

    work = df[base_cols].copy()

    # Stable repo key for nunique counts
    if repo_id_col:
        work["_repo_key"] = work[repo_id_col]
    else:
        work["_repo_key"] = work.index

    # booleans -> 0/1, then mean = pass rate
    work["tf_linter"] = work[cols["tflint_pass"]].apply(to_bool_or_na).map({True: 1, False: 0})
    work["checkov_pass"] = work[cols["checkov_pass"]].apply(to_bool_or_na).map({True: 1, False: 0})

    # checkov counts
    work["checkov_failed"] = work[cols["checkov_failed"]].apply(to_int_or_na)
    work["checkov_passed"] = work[cols["checkov_passed"]].apply(to_int_or_na)
    work["checkov_count"] = work["checkov_failed"] + work["checkov_passed"]

    # tflint counts (prefer parsing JSON artifact if column exists)
    if tflint_json_col:
        cache: Dict[str, Optional[Dict[str, int]]] = {}

        def get_tflint_triplet(x: Any) -> Tuple[Optional[int], Optional[int], Optional[int]]:
            try:
                if pd.isna(x):
                    return (None, None, None)
            except Exception:
                pass
            s = str(x).strip()
            if not s:
                return (None, None, None)

            p = resolve_artifact_path(csv_path, s)
            key = str(p)
            if key not in cache:
                cache[key] = parse_tflint_counts_from_json_file(p)
            c = cache[key]
            if not c:
                return (None, None, None)
            return (c.get("low", 0), c.get("medium", 0), c.get("high", 0))

        triplets = work[tflint_json_col].apply(get_tflint_triplet)
        work["tf_lint_low"] = triplets.apply(lambda t: t[0])
        work["tf_lint_medium"] = triplets.apply(lambda t: t[1])
        work["tf_lint_high"] = triplets.apply(lambda t: t[2])
    else:
        # Fallback to existing numeric columns if no JSON path is available
        tflint_low_col = pick_existing_column(df, ["metrics.tflint_low", "norm.tflint_low", "tflint_low"])
        tflint_medium_col = pick_existing_column(df, ["metrics.tflint_medium", "norm.tflint_medium", "tflint_medium"])
        tflint_high_col = pick_existing_column(df, ["metrics.tflint_high", "norm.tflint_high", "tflint_high"])
        work["tf_lint_low"] = df[tflint_low_col].apply(to_int_or_na)
        work["tf_lint_medium"] = df[tflint_medium_col].apply(to_int_or_na)
        work["tf_lint_high"] = df[tflint_high_col].apply(to_int_or_na)

    # aggregate per kind: mean for pass rates, median for counts
    out_df = (
        work.groupby("kind", dropna=False)
        .agg(
            tf_linter=("tf_linter", "mean"),
            tf_lint_low=("tf_lint_low", "median"),
            tf_lint_medium=("tf_lint_medium", "median"),
            tf_lint_high=("tf_lint_high", "median"),
            checkov_pass=("checkov_pass", "mean"),
            checkov_failed=("checkov_failed", "median"),
            checkov_count=("checkov_count", "median"),
        )
        .reset_index()
        .sort_values("kind")
        .reset_index(drop=True)
    )

    # NEW: per-kind repo counts with medium tflint (>0)
    repos_total = work.groupby("kind", dropna=False)["_repo_key"].nunique().rename("repos_total")
    repos_with_medium = (
        work.loc[work["tf_lint_medium"].fillna(0) > 0]
        .groupby("kind", dropna=False)["_repo_key"]
        .nunique()
        .rename("tf_lint_medium_repos")
    )

    medium_stats = (
        pd.concat([repos_total, repos_with_medium], axis=1)
        .fillna({"tf_lint_medium_repos": 0})
        .reset_index()
        .sort_values("kind")
        .reset_index(drop=True)
    )
    medium_stats["tf_lint_medium_repos"] = medium_stats["tf_lint_medium_repos"].astype(int)

    # Print main table
    with pd.option_context("display.max_columns", 50, "display.width", 200):
        print(out_df.round(3).to_string(index=False))

    # Print requested counts
    print("\nRepos with MEDIUM TFLint issues per kind (tf_lint_medium > 0):")
    with pd.option_context("display.max_columns", 50, "display.width", 200):
        print(medium_stats.to_string(index=False))

    # LaTeX row fragments (original table)
    print("\nLaTeX rows (copy-paste):")
    for _, r in out_df.iterrows():
        kind = str(r["kind"])
        tf_linter = "" if pd.isna(r["tf_linter"]) else f"{float(r['tf_linter']):.2f}"
        tf_lint_low = "" if pd.isna(r["tf_lint_low"]) else f"{float(r['tf_lint_low']):.0f}"
        tf_lint_medium = "" if pd.isna(r["tf_lint_medium"]) else f"{float(r['tf_lint_medium']):.0f}"
        tf_lint_high = "" if pd.isna(r["tf_lint_high"]) else f"{float(r['tf_lint_high']):.0f}"
        checkov_pass = "" if pd.isna(r["checkov_pass"]) else f"{float(r['checkov_pass']):.2f}"
        checkov_failed = "" if pd.isna(r["checkov_failed"]) else f"{float(r['checkov_failed']):.0f}"
        checkov_count = "" if pd.isna(r["checkov_count"]) else f"{float(r['checkov_count']):.0f}"
        print(f"{kind} & {tf_linter} & {tf_lint_low} & {tf_lint_medium} & {tf_lint_high} & {checkov_pass} & {checkov_failed} & {checkov_count} \\\\")

    if args.out:
        out_df.to_csv(args.out, index=False)
        # also write medium stats alongside if you want it
        p = Path(args.out)
        medium_out = p.with_name(p.stem + "_tflint_medium_repos" + p.suffix)
        medium_stats.to_csv(medium_out, index=False)
        print(f"\nWrote: {args.out}")
        print(f"Wrote: {medium_out}")


if __name__ == "__main__":
    main()
