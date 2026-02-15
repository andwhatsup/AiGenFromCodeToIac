#!/usr/bin/env python3
"""
Batch-check repositories and output IDs that pass.

Configuration is via ENV VARS (CLI flags can still override):
  export CHECK_INPUT_FILE=repo_selection/candidates.txt
  export CHECK_OUTPUT_FILE=repo_selection/selected_ids.txt
  export CHECK_LOG_FILE=repo_selection/check_batch.log
  export CHECK_RECENCY_DAYS=365
  export CHECK_TF_CLI_VERSION=1.13.5
  # optional: private key to use for SSH clones
  export GIT_SSH_KEY=~/.ssh/id_ed25519

Input formats:
  - File (recommended): each line like  rid=<ID> url=<GIT_CLONE_URL>
  - Single repo via flags:  --rid 123 --url https://github.com/org/repo.git
  - Single repo inline:     'rid=123 url=https://github.com/org/repo.git'

Log line format:
  <ISO8601 ts> rid=<rid> url=<url> ok=<True|False> output=<reason|selected>
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from datetime import datetime
from pathlib import Path
from typing import Iterable, Optional, Tuple
from urllib.parse import urlparse

# ===== Defaults (can be left as-is) =====
DEFAULT_INPUT_FILE = "non_terraform_repos.log"
DEFAULT_OUT = "selected_ids.txt"
DEFAULT_LOG = "check_batch.log"
RECENCY_MIN_DAYS_DEFAULT = 0   # 2 years
RECENCY_MAX_DAYS_DEFAULT = 1095  # 3 years
CLI_VERSION_DEFAULT = "1.13.5"

# Known provider/version combos that fail on darwin_arm64 (Apple Silicon)
BLOCKED_PROVIDER_VERSIONS = {
    "registry.terraform.io/hashicorp/template": {"==": "2.2.0"},
}
MIN_AWS_PROVIDER = "4.0.0"  # reject constraints older than this

# ===== Small version helpers =====
def _split_ver(v: str) -> tuple[int, int, int]:
    parts = re.split(r"[.+-]", v.strip())
    nums = [int(x) for x in parts if x.isdigit()]
    while len(nums) < 3:
        nums.append(0)
    return tuple(nums[:3])

def _cmp(a: str, b: str) -> int:
    A, B = _split_ver(a), _split_ver(b)
    return (A > B) - (A < B)

def _satisfies_pessimistic(cli: str, v: str) -> bool:
    # "~> 1.2.3" => >=1.2.3 and <1.3.0 ; "~> 1.2" => >=1.2.0 and <2.0.0
    if v.count(".") >= 2:
        base = v.rsplit(".", 1)[0]
        major, minor = base.split(".")[:2]
        upper = f"{major}.{int(minor)+1}.0"
    else:
        major = v.split(".")[0]
        upper = f"{int(major)+1}.0.0"
    lo = v if "." in v else v + ".0.0"
    return _cmp(cli, lo) >= 0 and _cmp(cli, upper) < 0

def version_satisfies(cli: str, constraint_expr: str) -> bool:
    tokens = [t for t in re.split(r"[,\s]+", constraint_expr.strip()) if t]
    i, ok_all = 0, True
    while i < len(tokens):
        op = tokens[i]
        if op in {"=", "==", "!=", ">=", "<=", ">", "<", "~>"} and i + 1 < len(tokens):
            val = tokens[i+1]
            if op in {"=", "=="}: ok = (_cmp(cli, val) == 0)
            elif op == "!=":      ok = (_cmp(cli, val) != 0)
            elif op == ">=":      ok = (_cmp(cli, val) >= 0)
            elif op == "<=":      ok = (_cmp(cli, val) <= 0)
            elif op == ">":       ok = (_cmp(cli, val) > 0)
            elif op == "<":       ok = (_cmp(cli, val) < 0)
            elif op == "~>":      ok = _satisfies_pessimistic(cli, val)
            else:                  ok = True
            ok_all = ok_all and ok
            i += 2
        else:
            if re.match(r"^\d+(\.\d+){0,2}$", op):
                ok_all = ok_all and (_cmp(cli, op) == 0)
            i += 1
    return ok_all

# ===== Parsers (Terraform files) =====
RX_REQ_VERSION = re.compile(r'terraform\s*{[^}]*required_version\s*=\s*"([^"]+)"', re.I | re.S)
RX_REQ_PROV_BLOCK = re.compile(r'required_providers\s*{([^}]*)}', re.I | re.S)
RX_REQ_PROV_ENTRY = re.compile(
    r'([A-Za-z0-9_-]+)\s*=\s*{[^}]*?source\s*=\s*"[^"]*"\s*[^}]*?version\s*=\s*"([^"]+)"',
    re.I | re.S
)
RX_LOCK_PROVIDER = re.compile(r'\s*provider\s+"([^"]+)"\s*{', re.I)
RX_LOCK_VERSION  = re.compile(r'\bversion\s*=\s*"([^"]+)"', re.I)

def collect_tf_text(repo_root: Path) -> str:
    texts = []
    for p in list(repo_root.rglob("*.tf")) + list(repo_root.rglob("*.tf.json")):
        if ".terraform" in p.parts:
            continue
        try:
            texts.append(p.read_text(encoding="utf-8", errors="ignore"))
        except Exception:
            pass
    return "\n".join(texts)

def find_required_versions(blob: str) -> list[str]:
    return RX_REQ_VERSION.findall(blob or "")

def parse_required_providers(blob: str) -> dict[str, str]:
    res = {}
    for blk in RX_REQ_PROV_BLOCK.findall(blob or ""):
        for name, ver in RX_REQ_PROV_ENTRY.findall(blk):
            res[name.lower()] = ver.strip()
    return res

def parse_lockfile_providers(lockfile: Path) -> dict[str, str]:
    out, cur = {}, None
    if not lockfile.exists():
        return out
    for line in lockfile.read_text(encoding="utf-8", errors="ignore").splitlines():
        m = RX_LOCK_PROVIDER.match(line)
        if m:
            cur = m.group(1)
            continue
        if cur:
            mv = RX_LOCK_VERSION.search(line)
            if mv:
                out[cur] = mv.group(1)
            if line.strip() == "}":
                cur = None
    return out

# ===== App presence detectors =====
def has_app_presence(repo_root: Path) -> bool:
    if any((repo_root / n).exists() for n in ["Dockerfile", "docker-compose.yml", "Procfile", "manage.py"]):
        return True
    pj = repo_root / "package.json"
    if pj.exists():
        try:
            data = json.loads(pj.read_text(encoding="utf-8", errors="ignore"))
            scripts = {k.lower(): str(v).lower() for k, v in (data.get("scripts") or {}).items()}
            if any(k in scripts for k in ("start", "dev", "serve")):
                return True
            deps = {*(data.get("dependencies") or {}).keys(), *(data.get("devDependencies") or {}).keys()}
            if any(x in deps for x in ("express", "fastify", "koa", "nestjs", "next", "sveltekit")):
                return True
        except Exception:
            pass
    if any((repo_root / n).exists() for n in ["requirements.txt", "pyproject.toml", "setup.cfg", "app.py"]):
        return True
    if (repo_root / "go.mod").exists() and any(repo_root.rglob("**/main.go")):
        return True
    if ((repo_root / "pom.xml").exists() or (repo_root / "build.gradle").exists()) and (repo_root / "src" / "main").exists():
        return True
    if (repo_root / "Cargo.toml").exists() and (repo_root / "src" / "main.rs").exists():
        return True
    mk = repo_root / "Makefile"
    if mk.exists():
        try:
            txt = mk.read_text(encoding="utf-8", errors="ignore").lower()
            if re.search(r"^(run|start|serve)\s*:", txt, re.M):
                return True
        except Exception:
            pass
    return False

# ===== Terraform root detection =====
def _is_ancestor(a: Path, b: Path) -> bool:
    """True if a is a parent directory of b (and not equal)."""
    try:
        rel = b.resolve().relative_to(a.resolve())
        return rel != Path(".")
    except Exception:
        return False

def find_tf_roots(repo_root: Path):
    """All directories under repo_root that contain at least one *.tf or *.tf.json."""
    roots = set()
    for p in repo_root.rglob("*.tf"):
        if ".terraform" in p.parts:
            continue
        roots.add(p.parent.resolve())
    for p in repo_root.rglob("*.tf.json"):
        if ".terraform" in p.parts:
            continue
        roots.add(p.parent.resolve())
    return sorted(roots)

def find_leaf_tf_roots(repo_root: Path):
    """
    Leaf Terraform roots only:
    - find all roots with .tf files
    - drop any root that is a parent of another root
    """
    roots = find_tf_roots(repo_root)
    roots_sorted = sorted(roots, key=lambda p: (len(p.parts), str(p)))
    leaf = []
    for r in roots_sorted:
        if any(_is_ancestor(r, o) for o in roots_sorted if o is not r):
            # r is a parent of another root -> skip
            continue
        leaf.append(r)
    return leaf

# ===== URL → SSH normalizer =====
def normalize_to_ssh(url: str) -> str:
    """
    Convert HTTPS Git URLs to SSH form:
      https://github.com/OWNER/REPO.git  ->  git@github.com:OWNER/REPO.git
    Leaves SSH URLs unchanged (git@host:owner/repo.git, ssh://git@host/owner/repo.git).
    """
    if url.startswith("git@") or url.startswith("ssh://"):
        return url
    try:
        u = urlparse(url)
        if u.scheme in {"http", "https"} and u.netloc and u.path:
            path = u.path
            if path.startswith("/"):
                path = path[1:]
            return f"git@{u.hostname}:{path}"
    except Exception:
        pass
    return url  # fallback

# ===== Git helpers (SSH-only cloning) =====
def shallow_clone(url: str, dest: Path) -> Tuple[bool, str]:
    ssh_url = normalize_to_ssh(url)

    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"  # never prompt for username/password

    # Optional: force a particular key and accept-new host keys
    ssh_cmd = ["ssh", "-o", "StrictHostKeyChecking=accept-new", "-o", "ServerAliveInterval=30"]
    key_path = os.getenv("GIT_SSH_KEY")
    if key_path:
        ssh_cmd += ["-i", key_path]
    env["GIT_SSH_COMMAND"] = " ".join(ssh_cmd)

    try:
        subprocess.run(
            ["git", "clone", "--depth", "1", "--no-tags", "--filter=blob:none", ssh_url, str(dest)],
            check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True, env=env,
        )
        return True, ""
    except subprocess.CalledProcessError as e:
        return False, (e.stderr or "").strip()
    except Exception as e:
        return False, str(e)

def last_commit_age_days(repo_dir: Path) -> Optional[int]:
    try:
        cp = subprocess.run(
            ["git", "log", "-1", "--format=%ct"],
            cwd=str(repo_dir),
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
        )
        ts = int(cp.stdout.strip())
        return int((time.time() - ts) / 86400)
    except Exception:
        return None

# ===== Compatibility check (Terraform) =====
def is_repo_terraform_compatible(repo_root: Path, cli_version: str) -> Tuple[bool, str]:
    blob = collect_tf_text(repo_root)

    # required_version must allow our CLI
    for expr in find_required_versions(blob):
        if not version_satisfies(cli_version, expr):
            return False, f"required_version '{expr}' excludes Terraform {cli_version}"

    # lockfile pins
    lock = parse_lockfile_providers(repo_root / ".terraform.lock.hcl")
    for prov_key, ver in lock.items():
        blk = BLOCKED_PROVIDER_VERSIONS.get(prov_key)
        if blk and blk.get("==") == ver:
            return False, f"provider pin {prov_key}=={ver} blocked on darwin_arm64"

    # provider constraints — reject aws < 4.0.0; template pinned to 2.2.0
    req_prov = parse_required_providers(blob)
    if "aws" in req_prov:
        m = re.search(r"([=><~!]+)\s*([0-9.]+)", req_prov["aws"])
        if m and m.group(1) in {">=", "~>", "=", "=="}:
            lo = m.group(2)
            if _cmp(lo, MIN_AWS_PROVIDER) < 0:
                return False, f"aws provider constraint '{req_prov['aws']}' too old"
    if req_prov.get("template") in {"= 2.2.0", "== 2.2.0", "2.2.0"}:
        return False, "template provider pinned to 2.2.0"

    return True, ""

# ===== Logging =====
def log_line(log_path: Path, rid: str, url: str, ok: bool, output: str) -> None:
    ts = datetime.now().isoformat(timespec="seconds")
    log_path.parent.mkdir(parents=True, exist_ok=True)
    with log_path.open("a", encoding="utf-8") as f:
        f.write(f"{ts} rid={rid} url={url} ok={ok} output={output}\n")

# ===== Input parsing =====
def parse_inline(s: str) -> Optional[Tuple[str, str]]:
    m_r = re.search(r"\brid=([^\s]+)", s)
    m_u = re.search(r"\burl=([^\s]+)", s)
    if m_r and m_u:
        return m_r.group(1), m_u.group(1)
    return None

def read_pairs_from_file(path: Path) -> Iterable[Tuple[str, str]]:
    if not path.exists():
        return []
    with path.open("r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            got = parse_inline(line)
            if got:
                yield got

# ===== Core check =====
def check_one(rid: str, url: str, out_file: Path, log_file: Path, min_days: int, max_days: int, cli_version: str) -> bool:
    with tempfile.TemporaryDirectory(prefix="check-repo-") as tmpd:
        repo_dir = Path(tmpd) / rid
        ok_clone, clone_err = shallow_clone(url, repo_dir)
        if not ok_clone:
            log_line(log_file, rid, url, False, f"clone_failed: {clone_err[:300]}")
            return False

        # --- NEW: enforce exactly one Terraform root (leaf) ---
        leaf_roots = find_leaf_tf_roots(repo_dir)
        if not leaf_roots:
            log_line(log_file, rid, url, False, "no_tf_roots")
            return False
        if len(leaf_roots) > 1:
            # Log a short summary of roots for debugging
            rels = [str(r.relative_to(repo_dir)) for r in leaf_roots]
            summary = ", ".join(rels[:5])
            log_line(log_file, rid, url, False, f"multi_tf_roots:{len(leaf_roots)} [{summary}]")
            return False
        # If you ever need the single root path later, you can keep it:
        # single_root = leaf_roots[0]

        ok_tf, reason_tf = is_repo_terraform_compatible(repo_dir, cli_version)
        if not ok_tf:
            log_line(log_file, rid, url, False, f"tf_incompatible: {reason_tf}")
            return False

        age = last_commit_age_days(repo_dir)
        if age is None:
            log_line(log_file, rid, url, False, "commit_age_unknown")
            return False

        lo, hi = sorted((min_days, max_days))
        if not (lo <= age <= hi):
            log_line(log_file, rid, url, False, f"commit_age_out_of_range:{age}d want[{lo},{hi}]")
            return False

        if not has_app_presence(repo_dir):
            log_line(log_file, rid, url, False, "no_app_presence")
            return False

    out_file.parent.mkdir(parents=True, exist_ok=True)
    with out_file.open("a", encoding="utf-8") as f:
        f.write(f"{rid}\n")
    log_line(log_file, rid, url, True, "selected")
    print(rid)
    return True

# ===== CLI =====
def main() -> int:
    ap = argparse.ArgumentParser(description="Batch-check repositories and output IDs that pass.")
    ap.add_argument("inline", nargs="?", help="Inline input like: 'rid=123 url=https://...git'")
    ap.add_argument("--rid", help="Repository ID")
    ap.add_argument("--url", help="Clone URL")
    ap.add_argument("--input-file", help="File with lines 'rid=.. url=..'")
    ap.add_argument("--out", help=f"Output file (default from env CHECK_OUTPUT_FILE or {DEFAULT_OUT})")
    ap.add_argument("--log", help=f"Log file (default from env CHECK_LOG_FILE or {DEFAULT_LOG})")
    ap.add_argument("--min-days", type=int, help=f"Min commit age in days (default env CHECK_RECENCY_MIN_DAYS or {RECENCY_MIN_DAYS_DEFAULT})")
    ap.add_argument("--max-days", type=int, help=f"Max commit age in days (default env CHECK_RECENCY_MAX_DAYS or {RECENCY_MAX_DAYS_DEFAULT})")
    ap.add_argument("--cli-version", help=f"Terraform CLI version (default from env CHECK_TF_CLI_VERSION or {CLI_VERSION_DEFAULT})")
    args = ap.parse_args()

    # Resolve settings with precedence: CLI > ENV > DEFAULTS
    input_file = (
        args.input_file
        or os.getenv("CHECK_INPUT_FILE")
        or (DEFAULT_INPUT_FILE if Path(DEFAULT_INPUT_FILE).exists() else None)
    )
    out_file = Path(args.out or os.getenv("CHECK_OUTPUT_FILE") or DEFAULT_OUT)
    log_file = Path(args.log or os.getenv("CHECK_LOG_FILE") or DEFAULT_LOG)
    min_days = int(args.min_days or os.getenv("CHECK_RECENCY_MIN_DAYS") or RECENCY_MIN_DAYS_DEFAULT)
    max_days = int(args.max_days or os.getenv("CHECK_RECENCY_MAX_DAYS") or RECENCY_MAX_DAYS_DEFAULT)
    cli_v = str(args.cli_version or os.getenv("CHECK_TF_CLI_VERSION") or CLI_VERSION_DEFAULT)

    # Collect pairs from: file, flags, inline
    pairs: list[Tuple[str, str]] = []
    if input_file:
        pairs.extend(read_pairs_from_file(Path(input_file)))
    if args.rid and args.url:
        pairs.append((str(args.rid), str(args.url)))
    elif args.inline:
        got = parse_inline(args.inline)
        if got:
            pairs.append(got)

    if not pairs:
        print("No input repos. Provide --input-file or set CHECK_INPUT_FILE, or pass inline/flagged rid/url.", file=sys.stderr)
        return 2

    for rid, url in pairs:
        try:
            check_one(rid, url, out_file, log_file, min_days, max_days, cli_v)
        except Exception as e:
            log_line(log_file, rid, url, False, f"exception: {type(e).__name__}: {e}")

    return 0

if __name__ == "__main__":
    sys.stdout.reconfigure(line_buffering=True)
    sys.exit(main())
