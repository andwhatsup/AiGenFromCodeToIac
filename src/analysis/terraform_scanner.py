# analysis/terraform_scanner.py
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

# Optional HCL2 parser; fall back to regex if missing.
try:
    import hcl2  # type: ignore
    _HCL2 = True
except Exception:
    _HCL2 = False

IGNORED_DIRS = {
    ".git", ".hg", ".svn", ".terraform", ".terragrunt-cache",
    "node_modules", "venv", ".venv", "__pycache__",
}

_TF_FILE_RE = re.compile(r".+\.tf(?:vars(?:\.json)?)?$", re.IGNORECASE)
_RESOURCE_RE = re.compile(r'^\s*(resource|data)\s+"(aws_[^"]+)"\s+"[^"]+"\s*\{', re.MULTILINE)
_VARIABLE_RE = re.compile(r'^\s*variable\s+"([^"]+)"\s*\{([^}]*)\}', re.MULTILINE | re.DOTALL)
_DEFAULT_RE = re.compile(r'^\s*default\s*=\s*(.+)$', re.MULTILINE)
_TYPE_RE = re.compile(r'^\s*type\s*=\s*(.+)$', re.MULTILINE)
_PROVIDER_BLOCK_RE = re.compile(r'^\s*provider\s+"([^"]+)"\s*\{', re.MULTILINE)
_BACKEND_RE = re.compile(r'^\s*backend\s+"([^"]+)"\s*\{', re.MULTILINE)
_REQ_PROVIDERS_RE = re.compile(r'required_providers', re.IGNORECASE)

# ---------- Public API ----------

def find_terraform_roots(repo_dir: Path) -> List[Path]:
    """
    Return directories that contain at least one *.tf file and are not ignored.
    Heuristic: treat every dir with *.tf as a root, including env/module subdirs.
    """
    repo_dir = Path(repo_dir).resolve()
    roots: List[Path] = []
    for d in _iter_dirs(repo_dir):
        if any(p.suffix == ".tf" for p in d.glob("*.tf")):
            roots.append(d)
    # De-duplicate and keep stable order
    roots = sorted({p.resolve() for p in roots})
    return roots

def extract_required_variables(tf_root: Path) -> Dict[str, Dict[str, Optional[str]]]:
    """
    Return mapping of variable_name -> {"type": str|None, "has_default": bool, "default": str|None, "decl_file": str}
    Only variables without defaults are considered "required" by Terraform, but we return all with the flag for completeness.
    """
    out: Dict[str, Dict[str, Optional[str]]] = {}
    for f in _terraform_files(tf_root):
        try:
            if _HCL2:
                data = _parse_hcl_file(f)
                for block in data:
                    if "variable" in block:
                        for name, body in block["variable"].items():
                            entry = _variable_entry_from_hcl(body, decl_file=f)
                            out[name] = entry
            else:
                txt = f.read_text(encoding="utf-8", errors="ignore")
                for m in _VARIABLE_RE.finditer(txt):
                    name = m.group(1)
                    body = m.group(2)
                    has_default, default_val = _extract_default_regex(body)
                    vtype = _extract_type_regex(body)
                    out[name] = {
                        "type": vtype,
                        "has_default": has_default,
                        "default": default_val,
                        "decl_file": str(f),
                    }
        except Exception:
            # Never fail scanning due to one file; mark unknowns
            pass
    return out

def list_used_services(tf_root: Path) -> Tuple[Set[str], Dict[str, int]]:
    """
    Identify AWS service types from resource and data blocks.
    Returns (services, counts_by_type) where types look like 'aws_s3_bucket'.
    """
    services: Set[str] = set()
    counts: Dict[str, int] = {}
    for f in _terraform_files(tf_root):
        try:
            if _HCL2:
                data = _parse_hcl_file(f)
                _collect_services_hcl(data, services, counts)
            else:
                txt = f.read_text(encoding="utf-8", errors="ignore")
                for m in _RESOURCE_RE.finditer(txt):
                    rtype = m.group(2)
                    _bump(counts, rtype)
                    if rtype.startswith("aws_"):
                        services.add(rtype)
        except Exception:
            pass
    return services, counts

def detect_providers_and_backend(tf_root: Path) -> Dict[str, object]:
    """
    Collect provider declarations and backend type if any.
    Returns:
      {
        "providers": {"aws": {"decl_files": [...], "versions": set(str)} , ...},
        "backend": {"type": "s3"|"local"|..., "decl_files": [...] } or None
      }
    """
    providers: Dict[str, Dict[str, object]] = {}
    backend: Optional[Dict[str, object]] = None

    for f in _terraform_files(tf_root):
        try:
            if _HCL2:
                data = _parse_hcl_file(f)
                # provider blocks
                for block in data:
                    if "provider" in block:
                        for name, body in block["provider"].items():
                            p = providers.setdefault(name, {"decl_files": set(), "versions": set()})
                            p["decl_files"].add(str(f))
                    if "terraform" in block:
                        tfb = block["terraform"]
                        # required_providers
                        req = tfb.get("required_providers")
                        if isinstance(req, dict):
                            for name, spec in req.items():
                                p = providers.setdefault(name, {"decl_files": set(), "versions": set()})
                                p["decl_files"].add(str(f))
                                ver = _extract_version_from_req_provider(spec)
                                if ver:
                                    p["versions"].add(ver)
                        # backend
                        if "backend" in tfb and isinstance(tfb["backend"], dict):
                            for btype in tfb["backend"].keys():
                                if backend is None:
                                    backend = {"type": btype, "decl_files": {str(f)}}
                                else:
                                    backend["decl_files"].add(str(f))
            else:
                txt = f.read_text(encoding="utf-8", errors="ignore")
                for m in _provider_blocks_regex(txt):
                    name = m
                    p = providers.setdefault(name, {"decl_files": set(), "versions": set()})
                    p["decl_files"].add(str(f))
                if _REQ_PROVIDERS_RE.search(txt):
                    # naive: attempt to capture versions like = ">= 5.0"
                    for name, ver in _extract_required_providers_regex(txt):
                        p = providers.setdefault(name, {"decl_files": set(), "versions": set()})
                        p["decl_files"].add(str(f))
                        if ver:
                            p["versions"].add(ver)
                b = _backend_block_regex(txt)
                if b:
                    if backend is None:
                        backend = {"type": b, "decl_files": {str(f)}}
                    else:
                        backend["decl_files"].add(str(f))
        except Exception:
            pass

    # normalize sets -> lists for JSONability
    for v in providers.values():
        v["decl_files"] = sorted(v["decl_files"])  # type: ignore
        v["versions"] = sorted(v["versions"])      # type: ignore
    if backend:
        backend["decl_files"] = sorted(backend["decl_files"])  # type: ignore
    return {"providers": providers, "backend": backend}

def list_existing_varfiles(tf_root: Path) -> List[Path]:
    """
    Return existing tfvars files in root, respecting Terraform load order habits.
    """
    patterns = [
        "*.auto.tfvars", "*.auto.tfvars.json",
        "terraform.tfvars", "terraform.tfvars.json",
        "*.tfvars", "*.tfvars.json",
    ]
    out: List[Path] = []
    for pat in patterns:
        out.extend(sorted(tf_root.glob(pat)))
    # de-duplicate while preserving order
    seen = set()
    uniq: List[Path] = []
    for p in out:
        if p.resolve() not in seen:
            seen.add(p.resolve())
            uniq.append(p)
    return uniq

def scan_root(tf_root: Path) -> Dict[str, object]:
    """
    One-stop scan summary for a Terraform root directory.
    """
    tf_root = Path(tf_root).resolve()
    variables = extract_required_variables(tf_root)
    services, counts = list_used_services(tf_root)
    pb = detect_providers_and_backend(tf_root)
    varfiles = [str(p) for p in list_existing_varfiles(tf_root)]

    required_missing = sorted([name for name, meta in variables.items() if not meta.get("has_default")])

    return {
        "root": str(tf_root),
        "variables": variables,
        "required_missing": required_missing,  # variables with no default
        "aws_services": sorted(services),
        "resource_type_counts": counts,
        "providers": pb["providers"],
        "backend": pb["backend"],
        "existing_varfiles": varfiles,
    }

# ---------- Internals ----------

def _iter_dirs(root: Path):
    for dirpath, dirnames, filenames in _safe_walk(root):
        d = Path(dirpath)
        # prune ignored dirs in-place
        dirnames[:] = [n for n in dirnames if n not in IGNORED_DIRS]
        yield d

def _safe_walk(root: Path):
    # wrapper to guard against permission errors
    try:
        yield from _os_walk(root)
    except Exception:
        return

def _os_walk(root: Path):
    # Local reimplementation to avoid importing os.walk at top-level unnecessarily
    import os
    for dirpath, dirnames, filenames in os.walk(root, followlinks=False):
        yield dirpath, dirnames, filenames

def _terraform_files(d: Path) -> List[Path]:
    return sorted([p for p in d.glob("*.tf") if p.is_file()])

def _parse_hcl_file(path: Path):
    with path.open("r", encoding="utf-8") as fp:
        return hcl2.load(fp)  # type: ignore

def _variable_entry_from_hcl(body: dict, decl_file: Path) -> Dict[str, Optional[str]]:
    # body is typically a dict with keys like "default", "type", "description"
    has_default = "default" in body
    default_val = None
    if has_default:
        try:
            default_val = json.dumps(body["default"], ensure_ascii=False)
        except Exception:
            default_val = str(body["default"])
    vtype = None
    if "type" in body:
        try:
            vtype = json.dumps(body["type"], ensure_ascii=False)
        except Exception:
            vtype = str(body["type"])
    return {
        "type": vtype,
        "has_default": bool(has_default),
        "default": default_val,
        "decl_file": str(decl_file),
    }

def _collect_services_hcl(data, services: Set[str], counts: Dict[str, int]) -> None:
    # HCL2 parse tree is a list of blocks at top-level
    for block in data:
        if "resource" in block:
            for rtype, entries in block["resource"].items():
                _bump(counts, rtype)
                if rtype.startswith("aws_"):
                    services.add(rtype)
        if "data" in block:
            for rtype, entries in block["data"].items():
                _bump(counts, rtype)
                if rtype.startswith("aws_"):
                    services.add(rtype)

def _extract_default_regex(body: str) -> Tuple[bool, Optional[str]]:
    m = _DEFAULT_RE.search(body)
    if not m:
        return False, None
    # keep raw RHS to avoid incorrect evaluation
    return True, m.group(1).strip()

def _extract_type_regex(body: str) -> Optional[str]:
    m = _TYPE_RE.search(body)
    return m.group(1).strip() if m else None

def _provider_blocks_regex(txt: str) -> List[str]:
    return _PROVIDER_BLOCK_RE.findall(txt)

def _backend_block_regex(txt: str) -> Optional[str]:
    m = _BACKEND_RE.search(txt)
    return m.group(1) if m else None

def _extract_required_providers_regex(txt: str) -> List[Tuple[str, Optional[str]]]:
    """
    Very naive capture from required_providers block:
      aws = { source = "hashicorp/aws", version = "~> 5.0" }
    Returns list of (name, version_str|None)
    """
    out: List[Tuple[str, Optional[str]]] = []
    # capture lines like: name = { ... version = "..." ... }
    block_re = re.compile(r'(\w+)\s*=\s*\{[^}]*\}', re.DOTALL)
    for m in block_re.finditer(txt):
        name = m.group(1)
        frag = m.group(0)
        vm = re.search(r'version\s*=\s*"([^"]+)"', frag)
        ver = vm.group(1) if vm else None
        out.append((name, ver))
    return out

def _extract_version_from_req_provider(spec) -> Optional[str]:
    # spec may be {"source": "...", "version": "..." } or list; normalize to string if present
    if isinstance(spec, dict):
        v = spec.get("version")
        if isinstance(v, str):
            return v
    return None

def _bump(d: Dict[str, int], key: str) -> None:
    d[key] = d.get(key, 0) + 1
