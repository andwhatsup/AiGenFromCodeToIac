import json
from datetime import datetime
from pathlib import Path
from datetime import datetime

# ---- time + progress -----

def record_progress(app_id: int, status: str, *, meta: dict | None = None, error: str | None = None) -> None:
    PROGRESS_FILE = Path("log") / "progress.jsonl"
    ts = datetime.now().isoformat()
    rec = {"ts": ts, "app_id": app_id, "status": status}
    if meta:
        rec["meta"] = {k: (str(v) if isinstance(v, Path) else v) for k, v in meta.items()}
    if error:
        rec["error"] = error
    PROGRESS_FILE.parent.mkdir(parents=True, exist_ok=True)
    with PROGRESS_FILE.open("a", encoding="utf-8") as f:
        f.write(json.dumps(rec, ensure_ascii=False) + "\n")
