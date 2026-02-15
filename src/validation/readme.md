# Validation Module

Research and analysis scripts for post-pipeline metric computation and reporting.

## Purpose

Analyzes pipeline evaluation results to compute:
- Terraform validation pass rates (fmt, validate, init, plan, apply)
- Linting metrics (tflint issues, checkov violations)
- Iterative review statistics (how many fixes were needed)
- Per-application-kind breakdowns and comparisons

## Scripts

**RQ1.py** - Compute deployability pass rates

Reads `tf_validation/master_metrics.csv` and calculates pass rates for validation stages.

**Output**:
- Pass rates per kind (web_service, static_site, api, etc.)
- CSV export with long-form results
- Console summary table

**Metrics tracked**: fmt_ok, validate_ok, init_ok, plan_ok, apply_ok, tflint_pass, checkov_pass

---

**RQ3.py** - Linting and static analysis metrics

Computes per-kind statistics for tflint and checkov results.

**Output**:
- Mean pass rates
- Median issue/violation counts (low, medium, high severity)
- Repository counts with specific issue patterns

**Metrics tracked**: tflint_pass, checkov_pass, issue severity distribution

---

**count_iterative_reviews.py** - Iterative fix attempts analysis

Counts per-kind how many projects required multiple fix iterations (attempt_n > 1).

**Output**:
- Iterative review rate per application kind
- CSV with project-level iteration counts

**Details**:
- Parses `attempt_<n>` from run_dir paths in metrics CSV
- Excludes rows with missing run_dir

## Input Format

All scripts expect CSV input: `./tf_validation/master_metrics.csv`

**Typical columns**:
- `id` / `app_id` - Application identifier
- `kind` - Application type (web_service, static_site, etc.)
- `tf_fmt_ok`, `tf_validate_ok`, `tf_plan_ok`, `apply_ok` - Validation stage results
- `tflint_pass`, `checkov_pass` - Linting results
- `run_dir` - Path to evaluation artifacts (contains attempt_<n>)

## Usage

```bash
# Generate pass rate report
python RQ1.py --out results_rq1.csv

# Generate linting metrics
python RQ3.py --out results_rq3.csv

# Generate iterative review report
python count_iterative_reviews.py --out results_iterations.csv
```

## tf_validation Subdirectory

Extracts and normalizes evaluation metrics into master CSV.

**Purpose**: Convert raw evaluation artifacts (metrics.json, tflint.json, checkov.json, etc.) into a single normalized CSV for analysis.

**Files**:

- **cli.py** - Command-line interface for generating master_metrics.csv from evaluation results
  - Parses app IDs from file or CLI args
  - Calls extractors to build per-row metrics
  - Applies normalization layer
  - Exports to CSV with optional raw columns

- **master_extractor.py** - Extracts metrics from evaluation artifacts
  - Resolves run directories by app_id and kind
  - Locates artifacts recursively (metrics.json, plan.json, tflint.json, checkov.json, graph.dot)
  - Extracts summaries: pass/fail flags, issue counts, resource counts
  - Flattens nested JSON into flat columns

- **normalize.py** - Normalizes extracted metrics into stable schema
  - Coalesces multiple possible column name variants
  - Type casts: bool, int, float conversions
  - Derives tflint_total from severity counts
  - Projects repo_url from progress records

**Data Flow**:

```
Evaluation artifacts (per app_id, per kind)
          ↓
    master_extractor.py (locate & extract raw metrics)
          ↓
    normalize.py (standardize types & names)
          ↓
    cli.py (write master_metrics.csv)
          ↓
    RQ1.py, RQ3.py, etc. (analyze & report)
```

**Usage**:

```bash
cd src/validation/tf_validation

# Generate master metrics CSV
python cli.py \
  --results-root ../../../01_RESULTS \
  --out master_metrics.csv \
  --app-ids-file app_ids.txt \
  --include-raw
```

## Integration

- **Not part of main pipeline** - Run post-pipeline for analysis
- Operates on stored evaluation metrics
- Generates reports for research/benchmarking
- Data feeds research questions (RQ1, RQ3, etc.)
