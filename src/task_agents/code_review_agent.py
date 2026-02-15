from __future__ import annotations
from pathlib import Path
from typing import Any, List

from pydantic import BaseModel
from agents import Agent, ModelSettings, Runner, AgentOutputSchema
from agents.extensions.handoff_prompt import RECOMMENDED_PROMPT_PREFIX
from agents.mcp import MCPServerStdio


class CodeReviewResult(BaseModel):
    fixed: bool
    """Indicates whether the Terraform files were fixed successfully."""
    changes_made: List[str]
    """A list of changes made to the Terraform files."""


class CodeReviewAgent:
    """
    Terraform-aware code review agent.

    - External interface:
      `review_terraform(tf_dir: Path, error_context: Any)`.
    - Accepts both simple string error messages and structured context
      (evaluation_result + additional metadata).
    """

    def __init__(self, tf_dir: Path | None = None) -> None:
        # The tf_dir here is only used to set the root for the filesystem MCP.
        root = tf_dir or Path(".")

        self._fileSystem = MCPServerStdio(
            name="Filesystem",
            params={
                "command": "npx",
                "args": [
                    "-y",
                    "@modelcontextprotocol/server-filesystem",
                    str(root),
                ],
            },
            client_session_timeout_seconds=60,
        )
        self._tf = MCPServerStdio(
            name="Terraform Registry",
            params={
                "command": "docker",
                "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server:latest"],
            },
            client_session_timeout_seconds=60,
        )

        self.agent = Agent(
            name="Terraform Code Reviewer",
            model="gpt-5.2",
            model_settings=ModelSettings(
                temperature=0.0,
            ),
            handoff_description=(
                "Specialist agent that reviews and fixes Terraform configuration "
                "files based on evaluation errors and feedback."
            ),
            instructions=f"""{RECOMMENDED_PROMPT_PREFIX}

                You are an expert Terraform developer specializing in AWS infrastructure review and fixes.

                You have access to the following MCP servers:
                - Filesystem: {self._fileSystem.name} — for reading and writing Terraform files under the workspace root.
                - Terraform Registry: {self._tf.name} — for validating resources, arguments, and best practices.

                The workspace root corresponds to the 'tf_dir' parameter used when this agent is invoked.
                Terraform configuration is typically located under that root in one or more *.tf and *.tfvars files.

                Your task for each run:
                1. Read the provided context about the last Terraform evaluation failure.
                   The context may include:
                   - A high-level agent name indicating the intent (e.g. create_aws_terraform, analyze_codebase, etc.).
                   - A structured EvaluationResult (stage, errors, report_dir, etc.).
                   - Structured EvaluationFeedback (summary, hints, suggested_fix_agent).
                   - Or just a plain error message string.
                2. Inspect the Terraform configuration files in the workspace.
                3. Identify and fix the issues that caused the evaluation failure.
                4. Apply minimal, safe changes that follow AWS and Terraform best practices.
                5. Validate the updated configuration where possible (formatting, basic validation, cheap plan).
                6. Write back the fixed files.
                7. Return:
                   - `fixed`: whether the configuration is expected to pass evaluation now.
                   - `changes_made`: a concise bullet list describing the concrete changes you made.

                Guidelines:
                - Prefer small, targeted patches over large refactors.
                - Preserve existing semantics unless they are clearly wrong.
                - Maintain security best practices (least privilege IAM, encryption, secure networking, etc.).
                - Keep resources deterministic and consistent across modules and environments.
                """,
            mcp_servers=[self._fileSystem, self._tf],
            tools=[],
            output_type=AgentOutputSchema(CodeReviewResult, strict_json_schema=False),
        )

    async def __aenter__(self) -> "CodeReviewAgent":
        await self._fileSystem.connect()
        await self._tf.connect()
        return self

    async def __aexit__(self, exc_type, exc_value, traceback) -> None:
        try:
            await self._tf.cleanup()
            print("TF cleanup succeeded")
        except Exception as e:
            print(f"TF cleanup error: {e}")
        try:
            await self._fileSystem.cleanup()
            print("Filesystem cleanup succeeded")
        except Exception as e:
            print(f"Filesystem cleanup error: {e}")

    def _format_input(self, error_context: Any) -> str:
        """
        Accepts either:
        - a simple string error message, or
        - a dict containing `evaluation_result` / metadata, or
        - any other object that will be stringified.
        """
        if isinstance(error_context, str):
            ctx_str = error_context
        else:
            try:
                from pprint import pformat

                ctx_str = pformat(error_context, width=100)
            except Exception:
                ctx_str = str(error_context)

        return (
            "Context about the last Terraform evaluation failure:\n"
            f"{ctx_str}\n\n"
            "Use this information to locate and fix the relevant Terraform files in the workspace. "
            "After making changes, briefly summarise what you changed."
        )

    async def review_terraform(self, tf_dir: Path, error_context: Any) -> CodeReviewResult:
        """
        Review and attempt to fix Terraform in `tf_dir` using the provided error_context.

        `error_context` can be:
        - string error message (legacy behaviour),
        - dict with `evaluation_result` / metadata (new structured flow),
        - or any other object.
        """
        async with CodeReviewAgent(tf_dir) as reviewer:
            result = await Runner.run(
                reviewer.agent,
                input=reviewer._format_input(error_context),
                max_turns=20,
            )
            return result.final_output_as(CodeReviewResult)


# Single instance used as a namespace / factory, matching the old pattern.
code_review_agent = CodeReviewAgent(Path("."))
