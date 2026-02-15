# evaluation/eval_workflow/common.py
from __future__ import annotations

import shlex
import subprocess
from pathlib import Path
from typing import Optional, Tuple, Dict

def run(cmd: str, cwd: Path, env: Optional[Dict[str, str]] = None, timeout_s: int | None = None) -> Tuple[int, str, str]:
    try:
        p = subprocess.run(
            shlex.split(cmd),
            cwd=str(cwd),
            env=env,
            capture_output=True,
            text=True,
            timeout=timeout_s,
        )
        return p.returncode, p.stdout or "", p.stderr or ""
    except subprocess.TimeoutExpired as e:
        # Keep your existing convention: 124 == timeout
        out = e.stdout or ""
        err = e.stderr or ""
        # Ensure strings
        if isinstance(out, (bytes, bytearray)):
            out = out.decode(errors="replace")
        if isinstance(err, (bytes, bytearray)):
            err = err.decode(errors="replace")
        return 124, out, err or f"Command timed out after {timeout_s}s"
