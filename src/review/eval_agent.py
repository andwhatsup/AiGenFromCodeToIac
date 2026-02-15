from __future__ import annotations

from typing import Any, List, Literal, Optional

from pydantic import BaseModel
from agents import Agent, ModelSettings, Runner, AgentOutputSchema
from agents.extensions.handoff_prompt import RECOMMENDED_PROMPT_PREFIX


StageName = Literal[
    "PARSER",        # HCL parsing / fmt
    "VALIDATION",    # terraform validate, static checks
    "PLAN",          # terraform plan
    "POLICY",        # OPA / Conftest, security checks
    "ARCHITECTURE",  # higher-level rules / drift
]


class EvaluationError(BaseModel):
    """Normalized single error from Terraform evaluation."""

    code: str = "UNKNOWN"
    message: str
    file: Optional[str] = None
    line: Optional[int] = None
    resource: Optional[str] = None
    extra: dict[str, Any] = {}


class EvaluationResult(BaseModel):
    """
    Normalized result from your existing evaluate_dir(...) call.

    `raw` should contain the original dict from evaluate_dir for debugging.
    """

    ok: bool
    stage: Optional[StageName] = None
    errors: List[EvaluationError] = []
    attempt: int
    report_dir: str
    raw: dict[str, Any] = {}


class EvaluationFeedback(BaseModel):
    """
    Output of the eval agent. This is what you feed into the fixer agent.
    """

    stage: Optional[StageName] = None
    summary: str
    hints: List[str]
    suggested_fix_agent: str

class EvalAgent:
    """
    LLM-based evaluation agent that converts EvaluationResult into EvaluationFeedback.
    """

    def __init__(self) -> None:
        self.agent = Agent(
            name="Terraform Evaluation Feedback Agent",
            model="gpt-5.2",
            model_settings=ModelSettings(
                temperature=0.0,
            ),
            handoff_description=(
                "Generates structured feedback and selects the most appropriate fix agent "
                "based on Terraform evaluation results."
            ),
            instructions=f"""{RECOMMENDED_PROMPT_PREFIX}

            You are an expert in evaluating Terraform-based AWS infrastructure.

            You receive:
            - A JSON-encoded `EvaluationResult` object describing the last IaC evaluation.

            Your job is to produce an `EvaluationFeedback` JSON object with:
            - `summary`: 3–6 sentences explaining why evaluation failed and what is wrong at a high level.
            - `hints`: concrete, actionable bullet points for how to fix the problem in the next iteration.
            - `suggested_fix_agent`: choose ONE of:
            - "create_aws_terraform"
            - "create_aws_cloud_architecture"
            - "create_architecture"
            - "analyze_codebase"
            - "terraform_code_reviewer"
            - `stage`: either reuse the supplied stage or refine it if obvious.

            Routing guidance:
            - Use "create_aws_terraform" for straightforward Terraform syntax, validation, plan, and small resource wiring issues.
            - Use "create_aws_cloud_architecture" when the whole cloud design (VPC layout, security posture, cross-service design) is flawed.
            - Use "create_architecture" for broader software/system architecture mismatches between the app and the infra.
            - Use "analyze_codebase" when errors suggest that Terraform does not match the application code, requirements, or stack.
            - Use "terraform_code_reviewer" when a focused patch to the existing Terraform is sufficient and major redesign is not required.

            Always respond as a single JSON object that conforms to the `EvaluationFeedback` schema.
            """,
            tools=[],
            output_type=AgentOutputSchema(EvaluationFeedback, strict_json_schema=False),
        )
    def _format_input(
        self,
        evaluation_result: EvaluationResult,
    ) -> str:
        # Pydantic v2: use model_dump_json instead of .json(...)
        result_json = evaluation_result.model_dump_json(indent=2)

        return (
            "EvaluationResult object (JSON):\n"
            f"{result_json}\n\n"
            "Produce a JSON object that matches the EvaluationFeedback schema."
        )


    async def generate_feedback(
        self,
        evaluation_result: EvaluationResult,
        max_turns: int = 4,
    ) -> EvaluationFeedback:
        run_result = await Runner.run(
            self.agent,
            input=self._format_input(evaluation_result),
            max_turns=max_turns,
        )
        return run_result.final_output_as(EvaluationFeedback)


# Global instance you can import from your pipeline
eval_agent = EvalAgent()