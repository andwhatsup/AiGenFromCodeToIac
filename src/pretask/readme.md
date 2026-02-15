# Pretask Module

Preparation tasks: fetches repositories and manages Terraform files.

## Functions

**`fetch_source(db_path, app_id, repo_workdir, module_path) -> Tuple[Path, str]`**

Clones repository from SQLite database by app_id to working directory.

**Returns**: `(repo_dir, repo_url)` - Directory path and git URL

**Details**:
- Queries SQLite database for app_id → git URL mapping
- Converts HTTPS URLs to SSH (if needed)
- Performs shallow clone with `--depth=1 --filter=blob:none`
- Optionally checks out subdirectory specified by `module_path`
- Respects `GIT_SSH_KEY` environment variable

---

**`snapshot_terraform(root, app_id) -> Tuple[int, int]`**

Copies existing Terraform files/directories from repo to `out/<app_id>/og_tf/` (non-destructive).

**Returns**: `(files_copied, dirs_copied)` - Counts of copied artifacts

**Details**:
- Preserves original Terraform before purging
- Creates unique names if files conflict
- Targets: *.tf, *.tf.json, *.tfvars, terraform.lock.hcl, .terraform/ directories

---

**`purge_terraform(root) -> Tuple[int, int]`**

Removes all Terraform files and directories from repo (destructive).

**Returns**: `(files_removed, dirs_removed)` - Counts of removed artifacts

**Details**:
- Clears: *.tf, *.tf.json, .terraform/, terraform.lock.hcl, terraform state files
- Leaves source code intact
- Prepares clean workspace for AI IaC generation

## Files

- **fetch_source.py** - Clones repositories from SQLite database via git
- **remove_tf.py** - Snapshots and purges Terraform files from workspace
- **__init__.py** - Module exports

## Pipeline Integration

1. `fetch_source()` clones repo at pipeline start
2. Analysis runs on cloned source
3. Original Terraform evaluated (if present)
4. `snapshot_terraform()` archives original IaC
5. `purge_terraform()` removes Terraform for clean AI generation
