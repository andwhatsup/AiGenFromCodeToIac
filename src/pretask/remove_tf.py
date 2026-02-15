# pretask/remove_tf.py
import os
import shutil
import fnmatch
from pathlib import Path
from typing import Tuple

__all__ = ["snapshot_terraform", "purge_terraform"]

_TF_SUFFIXES = (".tf", ".tf.json", ".tfvars", ".tfvars.json")
_TF_EXACT = {"terraform.lock.hcl", ".terraform.lock.hcl"}
_TF_GLOBS = ("*.tfstate", "*.tfstate.*", "*tfvars*.sh")
_TF_DIRS = {
    ".terraform",
    "terraform",
    ".tf_plugin_cache",  # Plugin cache directory
    ".terraform.d",      # Local terraform directory
    "terraform.tfstate.d" # Terraform workspace state directory
}
_TF_DIR_PATTERNS = {
    ".terraform*",  # Matches .terraform and .terraform.d
    "terraform*",   # Matches terraform and terraform.tfstate.d
    ".tf_*",        # Matches .tf_plugin_cache and other tf-related dirs
}

def _unique_path(p: Path) -> Path:
    if not p.exists():
        return p
    stem, suffix = p.stem, p.suffix
    i = 1
    while True:
        cand = p.with_name(f"{stem}_{i}{suffix}")
        if not cand.exists():
            return cand
        i += 1

def snapshot_terraform(root: Path, app_id: int) -> Tuple[int, int]:
    """
    Copy Terraform files/dirs from `root` to ../out/<app_id>/og_tf/.
    Leaves the source repo untouched.
    """
    dest_root = (root / ".." / ".." / "out" / str(app_id) / "og_tf").resolve()
    dest_root.mkdir(parents=True, exist_ok=True)

    files_copied = 0
    dirs_copied = 0

    for dirpath, dirnames, filenames in os.walk(root):
        for d in list(dirnames):
            if d in _TF_DIRS:
                src_dir = Path(dirpath) / d
                rel = src_dir.relative_to(root)
                dst_dir = dest_root / rel
                dst_dir.parent.mkdir(parents=True, exist_ok=True)
                shutil.copytree(src_dir, _unique_path(dst_dir))
                dirnames.remove(d)
                dirs_copied += 1

        for fn in filenames:
            if (
                fn.endswith(_TF_SUFFIXES)
                or fn in _TF_EXACT
                or any(fnmatch.fnmatch(fn, pat) for pat in _TF_GLOBS)
            ):
                src = Path(dirpath) / fn
                rel = src.relative_to(root)
                dst = dest_root / rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, _unique_path(dst))
                files_copied += 1

    return files_copied, dirs_copied

def purge_terraform(root: Path) -> Tuple[int, int]:
    """
    Delete Terraform files/dirs in-place under `root`.
    """
    files_deleted = 0
    dirs_deleted = 0

    for dirpath, dirnames, filenames in os.walk(root):
        for d in list(dirnames):
            if any(fnmatch.fnmatch(d, pat) for pat in _TF_DIR_PATTERNS):
                p = Path(dirpath) / d
                shutil.rmtree(p, ignore_errors=True)
                dirnames.remove(d)
                dirs_deleted += 1

        for fn in list(filenames):
            if (
                fn.endswith(_TF_SUFFIXES)
                or fn in _TF_EXACT
                or any(fnmatch.fnmatch(fn, pat) for pat in _TF_GLOBS)
            ):
                p = Path(dirpath) / fn
                try:
                    p.unlink()
                    files_deleted += 1
                except Exception:
                    pass

    return files_deleted, dirs_deleted
