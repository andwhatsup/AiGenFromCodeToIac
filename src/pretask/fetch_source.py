# pretask/fetch_source.py
import os
import sqlite3
import subprocess
import shutil
from pathlib import Path
from typing import Optional, Tuple, List
from urllib.parse import urlparse

__all__ = ["fetch_source"]

# ----- git helpers -----

def _run_git(args: list, cwd: Optional[Path] = None, *, env: Optional[dict] = None) -> None:
    p = subprocess.run(["git"] + args, cwd=str(cwd) if cwd else None,
                       capture_output=True, text=True, env=env)
    if p.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed:\n{p.stdout}\n{p.stderr}")

def _sanitize_name(s: Optional[str], fallback: str) -> str:
    base = (s or fallback).strip()
    return base.replace("/", "__").replace("\\", "__").replace(" ", "_")

def _normalize_to_ssh(url: Optional[str]) -> Optional[str]:
    """
    Convert HTTPS Git URLs to SSH form:
      https://github.com/OWNER/REPO.git  ->  git@github.com:OWNER/REPO.git
    Leave native SSH URLs unchanged (git@host:owner/repo.git, ssh://git@host/owner/repo.git).
    Return None if input is falsy.
    """
    if not url:
        return None
    if url.startswith(("git@", "ssh://")):
        return url
    try:
        u = urlparse(url)
        if u.scheme in {"http", "https"} and u.netloc and u.path:
            path = u.path[1:] if u.path.startswith("/") else u.path
            return f"git@{u.hostname}:{path}"
    except Exception:
        pass
    return url

def _git_env_for_ssh() -> dict:
    """
    Non-interactive Git. Use default SSH config/agent unless GIT_SSH_KEY is set.
    """
    env = os.environ.copy()
    env["GIT_TERMINAL_PROMPT"] = "0"  # don't block for username/password

    key_path = os.getenv("GIT_SSH_KEY")
    if key_path:
        # Only force IdentityFile if explicitly provided
        ssh_cmd = [
            "ssh",
            "-o", "StrictHostKeyChecking=accept-new",
            "-o", "ServerAliveInterval=30",
            "-i", key_path,
        ]
        env["GIT_SSH_COMMAND"] = " ".join(ssh_cmd)
    # else: rely on default ssh (keys in ~/.ssh, ssh-agent, ~/.ssh/config)
    return env

# ----- sqlite helpers -----

def _list_tables(conn: sqlite3.Connection) -> List[str]:
    cur = conn.execute("SELECT name FROM sqlite_master WHERE type='table'")
    return [r[0] for r in cur.fetchall()]

def _list_columns(conn: sqlite3.Connection, table: str) -> List[str]:
    cur = conn.execute(f"PRAGMA table_info('{table}')")
    return [r[1] for r in cur.fetchall()]

def _fetch_repo_record(conn: sqlite3.Connection, repo_id: int) -> Optional[sqlite3.Row]:
    cur = conn.execute(
        """
        SELECT Id, Name, FullName, CloneUrl, SshUrl, GitUrl, HtmlUrl, LatestCommitSha
        FROM Repositories
        WHERE Id = ?
        """,
        (repo_id,),
    )
    return cur.fetchone()

def _fetch_first_module_path(conn: sqlite3.Connection, repo_id: int) -> Optional[str]:
    if "Modules" not in _list_tables(conn):
        return None
    cols = _list_columns(conn, "Modules")
    if not {"RepositoryId", "Path"}.issubset(set(cols)):
        return None
    cur = conn.execute(
        "SELECT Path FROM Modules WHERE RepositoryId = ? ORDER BY Id ASC LIMIT 1",
        (repo_id,),
    )
    row = cur.fetchone()
    return row[0] if row and row[0] else None

def _choose_ssh_url(row: sqlite3.Row) -> Optional[str]:
    """
    Prefer SshUrl; otherwise convert other URL forms to SSH.
    Fallback order: SshUrl → CloneUrl → GitUrl → HtmlUrl
    """
    for key in ("SshUrl", "CloneUrl", "GitUrl", "HtmlUrl"):
        val = row.get(key) if isinstance(row, dict) else row[key]
        ssh = _normalize_to_ssh(val)
        if ssh:
            return ssh
    return None

# ----- clone -----

def _clone_fresh_full(row: sqlite3.Row, workdir: Path) -> Path:
    workdir.mkdir(parents=True, exist_ok=True)
    repo_dir = workdir / str(row["Id"])
    if repo_dir.exists():
        shutil.rmtree(repo_dir)

    url = _choose_ssh_url(row)
    if not url:
        raise RuntimeError(f"No usable SSH clone URL for repository Id={row['Id']}")

    env = _git_env_for_ssh()
    _run_git(["clone", url, str(repo_dir)], env=env)  # full clone via SSH

    if row["LatestCommitSha"]:
        _run_git(["checkout", "--detach", row["LatestCommitSha"]], cwd=repo_dir, env=env)

    return repo_dir.resolve()

# ----- public API -----

def fetch_source(
    db_path: Path,
    app_id: int,
    repo_workdir: Path,
    module_path_override: Optional[str] = None,
) -> Tuple[Path, str]:
    """
    Clone repository for app_id over SSH.
    Return (repo_dir, repo_url). Does NOT move/purge Terraform.
    repo_url is the human HTML URL if present, otherwise the SSH URL.
    """
    if not db_path.exists():
        raise FileNotFoundError(f"DB not found: {db_path}")

    with sqlite3.connect(str(db_path)) as conn:
        conn.row_factory = sqlite3.Row

        repo = _fetch_repo_record(conn, app_id)
        if not repo:
            tables = _list_tables(conn)
            diag = [f"{t}: {_list_columns(conn, t)}" for t in tables]
            raise RuntimeError(
                f"Repository Id={app_id} not found in Repositories.\nSchema summary:\n" + "\n".join(diag)
            )

        repo_dir = _clone_fresh_full(repo, repo_workdir)
        # Prefer HTML URL for metadata; fallback to SSH URL we used
        html_url = repo["HtmlUrl"] if "HtmlUrl" in repo.keys() else None
        if not html_url:
            html_url = _choose_ssh_url(repo) or ""
        return repo_dir, html_url
