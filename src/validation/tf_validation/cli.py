#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Any, Dict, List

import normalize
import master_extractor  # expects: KINDS, extract_progress_map, build_row


def parse_app_ids(args: argparse.Namespace) -> List[str]:
    if args.app_ids:
        return [a.strip() for a in args.app_ids if a.strip()]
    if args.app_ids_file:
        txt = Path(args.app_ids_file).read_text(encoding="utf-8")
        return [ln.strip() for ln in txt.splitlines() if ln.strip() and not ln.strip().startswith("#")]
    raise SystemExit("Provide --app-ids or --app-ids-file")


def _sanitize_csv_cell(v: Any) -> Any:
    if isinstance(v, str):
        # keep CSV one-line-per-row
        return v.replace("\r\n", "\\n").replace("\n", "\\n").replace("\r", "\\r")
    return v


def write_csv(rows: List[Dict[str, Any]], out_csv: Path, include_raw: bool, norm_prefix: str) -> None:
    base_cols = normalize.BASE_FIELDS
    norm_cols = normalize.norm_fieldnames(prefix=norm_prefix)

    fieldnames = base_cols + norm_cols
    if include_raw:
        raw_cols = sorted({k for r in rows for k in r.keys() if k not in fieldnames})
        fieldnames = fieldnames + raw_cols

    out_csv.parent.mkdir(parents=True, exist_ok=True)
    with out_csv.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            safe_row = {k: _sanitize_csv_cell(r.get(k)) for k in fieldnames}
            w.writerow(safe_row)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--results-root", default="../../../01_RESULTS")
    ap.add_argument("--out", default="./master_metrics.csv")
    ap.add_argument("--app-ids", nargs="*")
    ap.add_argument("--app-ids-file")
    ap.add_argument("--kinds", nargs="*", help="Subset of kind names (default: all)")
    ap.add_argument("--no-normalize", action="store_true", help="Disable normalization layer")
    ap.add_argument("--norm-prefix", default="norm.", help="Prefix for normalized columns")
    ap.add_argument("--include-raw", action="store_true", help="Include all raw extracted columns too")
    args = ap.parse_args()

    results_root = Path(args.results_root)
    out_csv = Path(args.out)
    app_ids = parse_app_ids(args)

    kinds = master_extractor.KINDS
    if args.kinds:
        wanted = set(args.kinds)
        kinds = [k for k in kinds if k.kind in wanted]

    # Cache progress per directory (shared across kinds)
    progress_cache: Dict[str, Dict[str, Any]] = {}
    for spec in kinds:
        if spec.directory not in progress_cache:
            progress_cache[spec.directory] = master_extractor.extract_progress_map(results_root, spec.directory)

    rows: List[Dict[str, Any]] = []
    for app_id in app_ids:
        for spec in kinds:
            progress_index = progress_cache.get(spec.directory, {})
            row = master_extractor.build_row(results_root, spec, app_id, progress_index)
            if not args.no_normalize:
                normalize.apply_normalization(row, prefix=args.norm_prefix)
            rows.append(row)

    write_csv(rows, out_csv, include_raw=args.include_raw, norm_prefix=args.norm_prefix)
    print(f"Wrote {len(rows)} rows -> {out_csv}")


if __name__ == "__main__":
    main()
