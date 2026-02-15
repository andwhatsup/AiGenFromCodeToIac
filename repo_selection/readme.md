# Repo Selection Helper

Two-stage pipeline that filters and validates repositories to identify Terraform-deployable applications suitable for IaC code generation.

## Overview

This pipeline consists of two independent filtering stages:

1. **Stage 1** (`non_tf_filter_complete_repo.py`): URL-based exclusion filter
   - Removes known Terraform module/provider repositories
   - Outputs application repositories that may contain deployable code

2. **Stage 2** (`repoCheck3.py`): Deep validation filter
   - Clones repos and performs comprehensive compatibility checks
   - Validates Terraform syntax and constraints
   - Verifies application deployability characteristics
   - Outputs validated repository IDs ready for infrastructure generation

---

## Stage 1: non_tf_filter_complete_repo.py

**Purpose**: Quickly filter out Terraform-specific repositories (modules, providers) that are not application codebases.

### How it works

- Reads a log file containing repository metadata (rid and url per line)
- Applies regex patterns to exclude Terraform-related repositories:
  - URLs containing `terraform-aws-`, `terraform-azurerm-`, `terraform-google-`
  - URLs containing `-terraform-`, `-tf-`
  - URLs containing `/terraform-modules/`, `/terraform/`
  - Any URL containing the word `terraform` (case-insensitive)
- Writes filtered repos to output file in `rid=<ID> url=<URL>` format

### Input/Output

- **Input**: `complete_repo_urls.log`
  - Format: `rid=<ID> url=<GIT_CLONE_URL> ...` (one repo per line)
  - Example: `rid=12345 url=https://github.com/org/app.git`

- **Output**: `non_terraform_repos.log`
  - Format: Same as input (preserved rid=... url=... pairs)
  - Contains only repos that passed the exclusion filter

### Usage

```bash
python non_tf_filter_complete_repo.py
```

No CLI arguments needed—uses hardcoded filenames. To customize, edit the function call at the bottom:

```python
filter_repos(input_filename="your_input.log", output_filename="your_output.log")
```

---

## Stage 2: repoCheck3.py

**Purpose**: Validate that filtered repositories contain deployable applications with compatible Terraform code.

### How it works

For each repository, performs:

1. **Clone Detection** (SSH-based, shallow clone with blob:none filter)
   - Uses SSH instead of HTTPS (respects `GIT_SSH_KEY` env var)
   - Clones depth=1 to minimize bandwidth

2. **Terraform Root Detection**
   - Scans for `*.tf` and `*.tf.json` files
   - Enforces exactly one **leaf** Terraform root (no nested roots)
   - Rejects repos with no Terraform or multiple independent Terraform modules

3. **Terraform Compatibility Validation**
   - **required_version constraint**: Verifies CLI version satisfies `required_version` block
   - **Provider version constraints**: Enforces AWS provider >= 4.0.0, blocks template@2.2.0
   - **Lockfile validation**: Rejects darwin_arm64-incompatible provider pins
   - Supports version operators: `==`, `!=`, `>=`, `<=`, `>`, `<`, `~>` (pessimistic versioning)

4. **Commit Recency Check**
   - Validates commit age falls within specified date range
   - Default: between 0 and 1095 days (3 years)

5. **Application Presence Detection**
   - Checks for deployment indicators:
     - Docker files: `Dockerfile`, `docker-compose.yml`, `Procfile`
     - Node.js: `package.json` with start/dev/serve scripts or web frameworks
     - Python: `requirements.txt`, `pyproject.toml`, `setup.cfg`, `app.py`
     - Go: `go.mod` + `main.go`
     - Java: `pom.xml`/`build.gradle` + `src/main`
     - Rust: `Cargo.toml` + `src/main.rs`
     - Makefile with run/start/serve targets

### Input/Output

- **Input**: `non_terraform_repos.log` (from Stage 1) or CLI arguments
  - Format: `rid=<ID> url=<GIT_CLONE_URL>`
  - Multiple input methods:
    - File: `--input-file` or env `CHECK_INPUT_FILE`
    - Flags: `--rid <ID> --url <URL>`
    - Inline: `'rid=123 url=https://...'` as positional arg

- **Output**: `selected_ids.txt`
  - Format: One repository ID per line (just the ID, no URL)
  - Only repos passing all validation checks
  - Also prints each selected ID to stdout

- **Log**: `check_batch.log` (detailed results)
  - Format: `<ISO8601_timestamp> rid=<ID> url=<URL> ok=<True|False> output=<reason>`
  - Failure reasons: `clone_failed`, `no_tf_roots`, `multi_tf_roots`, `tf_incompatible`, `commit_age_out_of_range`, `no_app_presence`

### Configuration

All settings support three precedence levels: CLI flags > environment variables > defaults

| Setting | Env Var | CLI Flag | Default |
|---------|---------|----------|---------|
| Input file | `CHECK_INPUT_FILE` | `--input-file` | `non_terraform_repos.log` |
| Output file | `CHECK_OUTPUT_FILE` | `--out` | `selected_ids.txt` |
| Log file | `CHECK_LOG_FILE` | `--log` | `check_batch.log` |
| Min commit age (days) | `CHECK_RECENCY_MIN_DAYS` | `--min-days` | 0 |
| Max commit age (days) | `CHECK_RECENCY_MAX_DAYS` | `--max-days` | 1095 |
| Terraform CLI version | `CHECK_TF_CLI_VERSION` | `--cli-version` | 1.13.5 |
| Git SSH key | `GIT_SSH_KEY` | — | Auto-detected |

### Usage Examples

**Basic usage (file input)**:
```bash
python repoCheck3.py
```
Uses defaults: reads `non_terraform_repos.log`, writes `selected_ids.txt`

**With environment variables**:
```bash
export CHECK_INPUT_FILE=repos.txt
export CHECK_OUTPUT_FILE=valid_repos.txt
export CHECK_TF_CLI_VERSION=1.12.0
export GIT_SSH_KEY=~/.ssh/id_ed25519
python repoCheck3.py
```

**Single repository via flags**:
```bash
python repoCheck3.py --rid 98765 --url https://github.com/org/app.git --out single_result.txt
```

**Custom commit age filter** (repos 180-365 days old):
```bash
python repoCheck3.py --input-file candidates.txt --min-days 180 --max-days 365
```

---

## Complete Pipeline

Typical workflow:

```bash
# Stage 1: Filter out Terraform modules/providers
python non_tf_filter_complete_repo.py
# Reads: complete_repo_urls.log
# Writes: non_terraform_repos.log

# Stage 2: Validate remaining repos
python repoCheck3.py
# Reads: non_terraform_repos.log (or env CHECK_INPUT_FILE)
# Writes: selected_ids.txt (and check_batch.log with details)
```

The output `selected_ids.txt` contains repository IDs ready for infrastructure generation (fed into the main AI Terraform generation pipeline).