from __future__ import annotations
from pathlib import Path
from typing import Any, Optional

from .eval_agent import (
    StageName,
    EvaluationError,
    EvaluationResult,
    EvaluationFeedback,
)
# task agents
from task_agents.code_review_agent import code_review_agent  # Changed from review_terraform to code_review_agent

from utils import record_progress

async def dispatch_to_fix_agent(
    app_id: str,
    agent_name: str,
    tf_dir: Path,
    evaluation_result: EvaluationResult,
    feedback: EvaluationFeedback,
) -> None:
    """
    Route the evaluation result to the appropriate fix agent based on the `suggested_fix_agent`.
    """
    error_context: dict[str, Any] = {
        "feedback": feedback.model_dump(),
        "agent_name": agent_name,
    }

    record_progress(app_id,"start_code_review_agent",meta={"tf_dir": tf_dir, "error_context": error_context,})

    await code_review_agent.review_terraform(tf_dir, error_context)  # Changed to use the instance method


# -----------------------------------
# Evaluation normalization utilities
# -----------------------------------

def _normalize_stage(raw_stage: Any) -> Optional[StageName]:
    if raw_stage is None:
        return None

    s = str(raw_stage).upper()

    if s in {"PARSER", "VALIDATION", "PLAN", "POLICY", "ARCHITECTURE"}:
        return s  # type: ignore[return-value]

    # Loose mapping for legacy stage names
    if s in {"FMT", "SYNTAX"}:
        return "PARSER"
    if s in {"APPLY", "DEPLOYMENT"}:
        return "PLAN"

    return None


def normalize_raw_evaluation(
    raw: dict[str, Any],
    attempt: int,
    attempt_dir: Path,
) -> EvaluationResult:
    """
    Convert the dict returned by your existing evaluate_dir(...) into EvaluationResult.

    Call this after evaluate_dir(tf_dir, attempt_dir) in evaluate_ai_terraform.
    """
    ok = bool(raw.get("ok"))

    stage = _normalize_stage(raw.get("stage"))

    errors: list[EvaluationError] = []
    for e in raw.get("errors", []) or []:
        if isinstance(e, dict):
            errors.append(
                EvaluationError(
                    code=str(e.get("code") or e.get("kind") or "UNKNOWN"),
                    message=str(e.get("msg") or e.get("message") or e),
                    file=e.get("file"),
                    line=e.get("line"),
                    resource=e.get("resource"),
                    extra={
                        k: v
                        for k, v in e.items()
                        if k
                        not in {
                            "code",
                            "kind",
                            "msg",
                            "message",
                            "file",
                            "line",
                            "resource",
                        }
                    },
                )
            )
        else:
            errors.append(
                EvaluationError(
                    code="UNKNOWN",
                    message=str(e),
                )
            )

    return EvaluationResult(
        ok=ok,
        stage=stage,
        errors=errors,
        attempt=attempt,
        report_dir=str(raw.get("report_dir", attempt_dir)),
        raw=raw,
    )


def evaluate_dir_structured(
    raw_result: dict[str, Any],
    attempt: int,
    attempt_dir: Path,
) -> EvaluationResult:
    """
    Helper to turn the dict returned by evaluate_dir(...) into EvaluationResult.

    Usage pattern in evaluate_ai_terraform:

        raw = evaluate_dir(tf_dir, attempt_dir)
        eval_result = evaluate_dir_structured(raw, attempt, attempt_dir)
    """
    return normalize_raw_evaluation(raw_result, attempt=attempt, attempt_dir=attempt_dir)