from __future__ import annotations

from pathlib import Path
from typing import Dict, Any
import re
import shutil

# Patterns to detect ZIP-based Lambda packaging in Terraform
# We preserve indentation by capturing leading whitespace.
_FILENAME_ZIP_RX = re.compile(
    r'^(\s*)filename\s*=\s*".*?\.zip"\s*$',
    re.MULTILINE,
)

# Replace just the function call, keep the rest of the line (e.g. "source_code_hash = ...")
_HASH_ZIP_RX = re.compile(
    r'filebase64sha256\(".*?\.zip"\)',
)


def _ensure_lambda_dummy_tf(root: Path) -> bool:
    """
    Ensure a lambda dummy definition exists in this root providing:
    - local.lambda_dummy_zip
    - data.archive_file.lambda_dummy

    Uses evaluation template: override_lambda_dummy.tf (NO required_providers block)
    Returns True if created/rewritten, False if already OK.
    """
    root = root.resolve()

    template_path = Path(__file__).parent / "override_lambda_dummy.tf"
    if not template_path.exists():
        raise FileNotFoundError(f"override_lambda_dummy.tf not found at {template_path}")

    # Prefer an eval-scoped filename to avoid colliding with repo files
    eval_tf_path = root / "_eval_override_lambda_dummy.tf"

    # If we already created the eval override once, keep it
    if eval_tf_path.exists():
        (root / ".dummy").mkdir(parents=True, exist_ok=True)
        return False

    # If an old generated lambda_dummy.tf exists and contains required_providers, rewrite it
    legacy_tf_path = root / "lambda_dummy.tf"
    if legacy_tf_path.exists():
        try:
            legacy = legacy_tf_path.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            legacy = ""
        # Heuristic: only rewrite if it looks like the old generated dummy
        if 'data "archive_file" "lambda_dummy"' in legacy and "required_providers" in legacy:
            legacy_tf_path.write_text(
                template_path.read_text(encoding="utf-8"),
                encoding="utf-8",
            )
            (root / ".dummy").mkdir(parents=True, exist_ok=True)
            return True

    # Otherwise create a new eval override file
    shutil.copy2(template_path, eval_tf_path)
    (root / ".dummy").mkdir(parents=True, exist_ok=True)
    return True


def _normalize_lambda_zip_usage(root: Path) -> int:
    """
    Rewrite Lambda ZIP usage in this root to use the dummy archive:

    - filename = "...something.zip"
         -> filename         = local.lambda_dummy_zip
    - source_code_hash = filebase64sha256("...zip")
         -> source_code_hash = data.archive_file.lambda_dummy.output_base64sha256

    Returns number of .tf files changed.
    """
    changed_files = 0

    for tf in root.glob("*.tf"):
        try:
            txt = tf.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue

        # Only bother if this file even mentions aws_lambda_function
        if "resource \"aws_lambda_function\"" not in txt:
            continue

        new_txt = txt

        # Replace any 'filename = "...zip"' lines, preserving indentation
        def _filename_repl(match: re.Match) -> str:
            indent = match.group(1) or ""
            return f"{indent}filename         = local.lambda_dummy_zip"

        new_txt = _FILE_NAME_ZIP_SAFE_SUB(new_txt, _filename_repl)

        # Replace filebase64sha256("...zip") with dummy archive hash
        new_txt = _HASH_ZIP_RX.sub(
            "data.archive_file.lambda_dummy.output_base64sha256",
            new_txt,
        )

        if new_txt != txt:
            tf.write_text(new_txt, encoding="utf-8")
            changed_files += 1

    return changed_files


def _FILE_NAME_ZIP_SAFE_SUB(text: str, repl) -> str:
    """
    Wrapper around _FILENAME_ZIP_RX.sub that keeps behavior explicit.
    """
    return _FILENAME_ZIP_RX.sub(repl, text)


def normalize_lambdas_in_root(root: Path) -> int:
    """
    Public helper: normalize Lambda usage in a single Terraform root.

    - Ensures lambda_dummy.tf exists.
    - Rewrites Lambda 'filename' and 'source_code_hash' usage to the dummy ZIP.

    Returns number of .tf files changed in this root.
    """
    root = root.resolve()
    _ensure_lambda_dummy_tf(root)
    return _normalize_lambda_zip_usage(root)


def normalize_lambdas_from_gate(repo_dir: Path | str, gate: Dict[str, Any]) -> int:
    """
    Use gate.json to detect which recommended roots have Lambda, then:
    - add lambda_dummy.tf
    - rewrite Lambda resources in those roots to use the dummy ZIP.

    repo_dir: repository root (where the Terraform roots are located).
    gate:     parsed gate.json dictionary from analyze_repo.

    Returns total number of .tf files changed across all roots.
    """
    repo_dir = Path(repo_dir).resolve()
    services_report = gate.get("services_report") or {}
    recommended_roots = gate.get("recommended_roots") or []

    total_changed = 0

    for rel_root in recommended_roots:
        svc = services_report.get(rel_root) or {}
        by_service = svc.get("by_service") or {}
        has_lambda = "lambda" in by_service

        if not has_lambda:
            continue

        root_path = (repo_dir / rel_root).resolve()
        _ensure_lambda_dummy_tf(root_path)
        total_changed += _normalize_lambda_zip_usage(root_path)

    return total_changed
