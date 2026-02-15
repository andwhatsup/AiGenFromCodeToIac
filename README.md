# Leveraging Large Language Models for Infrastructure-as-Code Generation

**Autonomous infrastructure-as-code generation pipeline**: Analyzes application repositories and generates production-ready Terraform code for AWS deployment using AI agents.

## Thesis Information Overview

This repository contains:
- **Pipeline Implementation** - Complete IaC generation system in `src/main.py`
- **Research Results** - All evaluation data stored in `01_RESULTS/` directory
- **Evaluation Metrics** - Aggregated metrics in `src/validation/tf_validation/master_metrics.csv`
- **Analysis Scripts** - Research question analysis in `src/validation/` (RQ1.py, RQ3.py, etc.)

---

## Quick Start

### Prerequisites

- Python 3.10+
- OpenAI API key (stored in `openai.key`)
- Git access (SSH recommended)
- Terraform CLI (for validation)
- SQLite database with repository metadata

### Setup

```bash
# 1. Install dependencies
pip install -r requirements.txt
npm install

# 2. Create OpenAI API key file
echo "sk-..." > openai.key

# 3. Create app IDs list
echo "12345,67890,11111" > app_id_1.txt

# 4. Run pipeline
just run
```

### Accessing Results

- **Pipeline Results**: `01_RESULTS/` - Contains all per-app evaluation artifacts
- **Aggregated Metrics**: `src/validation/tf_validation/master_metrics.csv` - Combined metrics CSV
- **Progress Tracking**: `log/progress.jsonl` - Real-time pipeline progress

### Configuration

Set environment variables to override defaults:

```bash
export DB_PATH=/path/to/database.sqlite        # Repository metadata DB
export REPO_WORKDIR=/path/to/workspace         # Working directory for cloned repos
export MODULE_PATH=apps/mymodule               # Optional: subdirectory inside repo
export MAX_IAC_ITERS=5                         # Max fix iterations for Terraform
```

---

## Main Workflow

Implemented in [src/main.py](src/main.py), the pipeline executes the following stages for each application:

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. FETCH SOURCE                                                 │
│    • Clone repository from git                                  │
│    • Resolve app_id to git URL via database                    │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│ 2. ANALYZE REPOSITORY                                           │
│    • Parse deployment configs (Dockerfile, package.json, etc.)  │
│    • Detect application type and tech stack                     │
│    • Identify existing Terraform code                           │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│ 3. EVALUATE ORIGINAL TERRAFORM                                  │
│    • Validate existing Terraform code (if present)              │
│    • Run terraform plan/apply in LocalStack                     │
│    • Identify issues and incompatibilities                      │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│ 4. PURGE & SNAPSHOT                                             │
│    • Save original Terraform to output directory                │
│    • Remove Terraform from working directory                    │
│    • Clean slate for AI generation                              │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5a. GENERATE IaC - SIMPLE (Single AI Agent)                    │
│    • Fast baseline infrastructure generation                    │
│    • Minimal, deployable AWS resources                          │
│    • Output: ai_basis_tf/                                       │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5b. EVALUATE & FIX SIMPLE TERRAFORM                             │
│    • Validate generated Terraform                               │
│    • Run plan/apply in LocalStack                               │
│    • Auto-fix failures with Code Review Agent (up to N times)   │
│    • Output: log/<app_id>/ai_basis_eval/                       │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│ 5c. ARCHIVE SIMPLE TERRAFORM                                    │
│    • Move validated basis IaC to: out/<app_id>/ai_tf_base/     │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6a. GENERATE IaC - FULL (Multi AI Agents)                       │
│    1. Source Analyzer: Parse application structure              │
│    2. Architecture Creator: Design cloud architecture           │
│    3. AWS Cloud Architect: Map to AWS services                  │
│    4. Terraform Engineer: Generate Terraform files              │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
┌─────────────────────────────────────────────────────────────────┐
│ 6b. EVALUATE & FIX FULL TERRAFORM                               │
│    • Validate generated Terraform                               │
│    • Run plan/apply in LocalStack                               │
│    • Auto-fix failures with Code Review Agent (up to N times)   │
│    • Output: log/<app_id>/ai_eval/                              │
└──────────────────────┬──────────────────────────────────────────┘
                       ↓
         ✓ Done: Terraform files ready in workspace
```

---

## Project Structure

```
ai-gen-from-code-to-iac/
├── README.md                           # This file
├── src/
│   ├── main.py                        # Pipeline orchestration (see above workflow)
│   ├── task_agents/                   # AI agents for IaC generation
│   │   ├── source_analyzer.py         # Analyzes application source code
│   │   ├── architecture_creator.py    # Designs cloud architecture
│   │   ├── aws_cloud_architecture_creator.py  # Maps to AWS services
│   │   ├── aws_terraform_engineer.py  # Generates full Terraform
│   │   ├── aws_terraform_basis_engineer.py  # Generates minimal Terraform
│   │   └── code_review_agent.py       # Fixes Terraform errors iteratively
│   │   └── README.md                  # Detailed task agents documentation
│   │
│   ├── analysis/                      # Repository analysis
│   │   ├── repo_analyzer.py           # Detects app type, tech stack, deployment patterns
│   │   └── README.md                  # Analysis module documentation
│   │
│   ├── evaluation/                    # Terraform validation & execution
│   │   ├── evaluation.py              # Runs terraform validate/plan/apply in LocalStack
│   │   ├── eval_agent.py              # Evaluation result interpretation
│   │   ├── eval_workflow/             # Specialized evaluation workflows
│   │   └── README.md                  # Evaluation module documentation
│   │
│   ├── pretask/                       # Pre-pipeline preparation
│   │   ├── fetch_source.py            # Clone repos from DB
│   │   ├── remove_tf.py               # Snapshot & purge Terraform
│   │   └── README.md                  # Pre-task documentation
│   │
│   ├── review/                        # Terraform fix & review
│   │   ├── review_flow.py             # Orchestrates fix iterations
│   │   ├── eval_agent.py              # Interprets evaluation errors
│   │   └── README.md                  # Review module documentation
│   │
│   └── utils.py                       # Shared utilities (progress tracking, etc.)
│
├── repo_selection/                     # Repository candidate filtering
│   └── repoCheck3/
│       ├── readme.md                  # Two-stage repo selection pipeline
│       ├── non_tf_filter_complete_repo.py  # Stage 1: URL-based exclusion
│       └── repoCheck3.py              # Stage 2: Deep validation
│
├── log/                               # (Generated) Progress tracking & logs
│   ├── progress.jsonl                 # One JSON line per app_id run
│   └── <app_id>/                      # Per-app evaluation artifacts
│       ├── og_eval/                   # Original Terraform evaluation
│       ├── ai_basis_eval/             # Simple IaC evaluation
│       ├── ai_eval/                   # Full IaC evaluation
│       └── agent_log/                 # AI agent intermediate outputs
│
├── out/                               # (Generated) Final outputs
│   └── <app_id>/
│       ├── ai_tf_base/                # Validated simple Terraform
│       ├── og_tf/                     # Original Terraform snapshot
│       └── ai_tf/                     # (Optional) Validated full Terraform
│
├── workspace/                         # (Generated) Temporary working repos
│   └── <app_id>/
│       ├── ai_basis_tf/               # Simple generation working dir
│       ├── ai_tf/                     # Full generation working dir
│       └── <source files>             # Cloned repository content
│
├── openai.key                         # (Create) OpenAI API key
├── app_id_1.txt                       # (Create) Newline-separated app IDs
└── requirements.txt                   # Python dependencies
```

---

## Module Documentation

Each module has detailed readme files:

- **[task_agents/readme.md](src/task_agents/)** - AI agents for code analysis and IaC generation
- **[analysis/readme.md](src/analysis/)** - Application structure and deployment pattern detection
- **[evaluation/readme.md](src/evaluation/)** - Terraform validation and execution
- **[pretask/readme.md](src/pretask/)** - Source fetching and workspace preparation
- **[review/REAreadmeDME.md](src/review/)** - Automated Terraform fixing and review
- **[repo_selection/readme.md](repo_selection/)** - Repository filtering pipeline
- **[validation/readme.md](src/validation/)** - Evaluation metrics, analysis scripts, and research question implementations

---

## Progress Tracking

The pipeline automatically tracks progress in `log/progress.jsonl`:

```json
{"timestamp": "2025-01-15T10:30:45", "app_id": 12345, "status": "start"}
{"timestamp": "2025-01-15T10:30:50", "app_id": 12345, "status": "source_resolved", "meta": {"repo_url": "https://github.com/org/app"}}
{"timestamp": "2025-01-15T10:35:20", "app_id": 12345, "status": "ok"}
```

Key status values:
- `start` - Pipeline started for app
- `source_resolved` - Repository cloned and ready
- `source_analyzed` - Application type and structure identified
- `eval_repo_ok` / `eval_repo_fail` - Original Terraform validation result
- `iac_basis_generated` - Simple Terraform generated
- `eval_ai_basis_ok` / `eval_ai_basis_fail` - Simple Terraform validation result
- `iac_generated` - Full Terraform generated
- `eval_ai_ok` / `eval_ai_fail` - Full Terraform validation result
- `ok` - All stages completed successfully
- `error` - Pipeline failed with exception

Resume partial runs by running the pipeline again—it automatically skips completed app IDs.

---

## Evaluation & Metrics

### Master Metrics CSV

After pipeline execution, aggregate results using:

```bash
cd src/validation/tf_validation
python cli.py \
  --results-root ../../../01_RESULTS \
  --out master_metrics.csv \
  --app-ids-file app_ids.txt
```

**Output**: `master_metrics.csv` with columns:
- Validation stages: `fmt_ok`, `validate_ok`, `init_ok`, `plan_ok`, `apply_ok`
- Linting: `tflint_pass`, `tflint_low`, `tflint_medium`, `tflint_high`
- Policy: `checkov_pass`, `checkov_failed`, `checkov_skipped`
- Terraform graph: `graph_nodes`, `graph_edges`
- Attempt tracking: `attempt_policy`, iteration counts

### Analysis Scripts

Generate research question reports:

```bash
# RQ1: Deployability pass rates
python src/validation/RQ1.py --out results_rq1.csv

# RQ3: Linting metrics
python src/validation/RQ3.py --out results_rq3.csv

# Iterative review statistics
python src/validation/count_iterative_reviews.py --out results_iterations.csv
```

---

## Typical Workflow: Repository Selection → Pipeline

### Step 1: Select Candidate Repositories

Use the two-stage filtering pipeline to identify deployable application repositories:

```bash
cd repo_selection/repoCheck3/

# Stage 1: Filter out Terraform modules and providers
python non_tf_filter_complete_repo.py
# Input: complete_repo_urls.log
# Output: non_terraform_repos.log

# Stage 2: Deep validation (compatibility, presence checks)
python repoCheck3.py
# Input: non_terraform_repos.log
# Output: selected_ids.txt
```

See [repo_selection/readme.md](repo_selection/readme.md) for details.

### Step 2: Run IaC Generation Pipeline

```bash
cd /path/to/vsc/master/ai-gen-from-code-to-iac

# Create app ID list from selected_ids.txt
cp ../repo_selection/repoCheck3/selected_ids.txt app_id_1.txt

# Run pipeline
python src/main.py
```

Monitor progress:
```bash
tail -f log/progress.jsonl                    # Live progress
tail -f log/<app_id>/ai_eval/terraform.log    # Specific app evaluation
```

---

## Output Artifacts

### For Each Application (`app_id`):

**Directory: `out/<app_id>/`**
- `og_tf/` - Original Terraform code from repository (snapshot)
- `ai_tf_base/` - Validated simple AI-generated Terraform
- `ai_tf/` - (Optional) Validated full AI-generated Terraform

**Directory: `log/<app_id>/`**
- `og_eval/` - Evaluation results of original Terraform
- `ai_basis_eval/` - Evaluation & fix attempts for simple IaC
- `ai_eval/` - Evaluation & fix attempts for full IaC
- `agent_log/` - Intermediate AI agent outputs

---

## Environment & Dependencies

### Required Tools

- Python 3.10+
- Git (SSH access recommended)
- Terraform CLI (for validation)
- Docker (for LocalStack evaluation backend)

### OpenAI Models

By default uses GPT-4.5-2 for:
- Source code analysis
- Architecture design
- AWS infrastructure planning
- Terraform code generation
- Error diagnosis and fixing

Override with env var:
```bash
export MODEL=gpt-4o
python src/main.py
```

### Database

SQLite database with schema:
- `repositories` table: repository metadata
- Columns: `app_id`, `url`, `name`, etc.

Set path:
```bash
export DB_PATH=/path/to/custom.sqlite
```

---

## Troubleshooting

### Common Issues

**Pipeline skips repos without output:**
- Check `log/progress.jsonl` for failure reason
- Review `log/<app_id>/` evaluation logs for details
- Example error: `source_analyzed`, then `eval_repo_fail` = repo has broken original Terraform

**Generated Terraform fails validation:**
- Check `log/<app_id>/ai_eval/terraform.log` for error details
- Code Review Agent attempts up to `MAX_IAC_ITERS` fixes
- If still failing, error context is logged for manual review

**SSH clone failures:**
- Verify Git SSH key is authorized
- Set `GIT_SSH_KEY` if needed:
  ```bash
  export GIT_SSH_KEY=~/.ssh/id_ed25519
  python src/main.py
  ```

---

## Development

### Adding a New Task Agent

1. Create new file in `src/task_agents/your_agent.py`
2. Define output model (inherits `BaseModel`)
3. Implement async agent function
4. Call from `src/main.py` workflow
5. Document in `src/task_agents/README.md`

### Running Single App (Debugging)

Modify `app_id_1.txt` to contain only the target app ID, then run `main.py`.

---

## License

MIT License

Copyright (c) 2026 andwhatsup

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Support

This project is provided as-is without official support. Issues and contributions are welcome via GitHub, but response times may vary. Use at your own risk for production workloads.
