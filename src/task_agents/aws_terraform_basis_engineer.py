# evaluation/task_agents/aws_terraform_basis_engineer.py
from __future__ import annotations

from pathlib import Path
from typing import Optional

from agents import Agent, ModelSettings, Runner
from agents.extensions.handoff_prompt import RECOMMENDED_PROMPT_PREFIX
from agents.mcp import MCPServerStdio
from pydantic import BaseModel


class AWSTerraformFile(BaseModel):
    name: str
    content: str


class AWSTerraformFilesOutput(BaseModel):
    files: list[AWSTerraformFile]


class AWSTerraformRepoEngineer:
    """
    Autonomous Terraform generator:
      - Scans the repo directly
      - Infers a minimal, deployable AWS architecture
      - Writes Terraform files to a dedicated workspace directory
      - Runs terraform init + validate (via AWS Terraform MCP) and iterates until validate passes
    """

    def __init__(
        self,
        codebase_path: str,
        app_id: int,
        *,
        output_subdir: str = "ai_basis_tf",
        model: str = "gpt-5.2",
        max_turns: int = 40,
    ):
        self._codebase_path = codebase_path
        self._app_id = app_id
        self._max_turns = max_turns

        # Workspace directory for this variant
        self._workspace_dir = Path(f"./workspace/{app_id}/{output_subdir}")
        self._workspace_dir.mkdir(parents=True, exist_ok=True)

        # MCP: filesystem server with two roots:
        #  - repo root (read)
        #  - workspace root (write)
        self._fileSystem = MCPServerStdio(
            name="Filesystem",
            params={
                "command": "npx",
                "args": [
                    "-y",
                    "@modelcontextprotocol/server-filesystem",
                    self._codebase_path,
                    str(self._workspace_dir),
                ],
            },
            client_session_timeout_seconds=300,
        )

        self._tf_registry = MCPServerStdio(
            name="Terraform Registry",
            params={
                "command": "docker",
                "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server:latest"],
            },
            client_session_timeout_seconds=90,
        )

        self._aws_tf = MCPServerStdio(
            name="AWS Terraform",
            params={
                "command": "uvx",
                "args": ["awslabs.terraform-mcp-server@latest"],
                "env": {"FASTMCP_LOG_LEVEL": "ERROR"},
            },
            client_session_timeout_seconds=180,
        )

        self.agent = Agent(
            name="AWS Terraform Repo Engineer",
            model=model,
            model_settings=ModelSettings(temperature=0.0),
            handoff_description=(
                "Autonomous agent that scans a code repository and generates Terraform files "
                "to provision AWS infrastructure with a goal of successful deployment."
            ),
            instructions=self._build_instructions(),
            mcp_servers=[self._fileSystem, self._tf_registry, self._aws_tf],
            tools=[],
            output_type=AWSTerraformFilesOutput,
        )

    def _build_instructions(self) -> str:
        ws = str(self._workspace_dir)
        repo = str(Path(self._codebase_path).resolve())
        return f"""{RECOMMENDED_PROMPT_PREFIX}

        You are an expert Terraform developer specializing in AWS infrastructure.

        Goal
        - Scan the repository and infer the minimal AWS infrastructure required to run the application.
        - Generate VALID Terraform code that can be initialized and validated successfully.
        - Write all Terraform files into the workspace directory: {ws}

        Repository root (read-only):
        - {repo}

        Workspace root (write):
        - {ws}

        Hard requirements
        1) You MUST scan the repo using the Filesystem MCP server:
        - Read README, Dockerfile, docker-compose, package.json, requirements.txt, pyproject.toml, go.mod, pom.xml/build.gradle,
            and any deployment configs.
        - Identify app type: static frontend, web API, containerized app, serverless, etc.
        2) Decide on a minimal deployment target:
        - Prefer the simplest deployable AWS pattern.
        - If uncertain, prefer a conservative baseline that is likely to validate and apply in LocalStack-style environments:
            - Avoid CloudFormation stacks/custom resources.
            - Avoid EKS/NAT Gateways unless clearly required.
            - Prefer data sources for default VPC/subnets rather than building a full VPC from scratch.
        3) Generate Terraform files:
        - versions.tf (terraform + required_providers)
        - provider.tf (aws provider + region variable)
        - variables.tf
        - outputs.tf
        - main.tf (and additional *.tf files as needed)
        4) Write every generated file to {ws} using the Filesystem MCP server.
        5) Use AWS Terraform MCP server to run:
        - terraform init (in {ws})
        - terraform validate (in {ws})
        Iterate until validate succeeds. Do NOT use checkov.
        6) Output MUST be a list of files (name + content). The written files must match that output.

        Implementation guidance (use best judgement)
        - Use variables for region, app_name, etc.
        - Add tags where reasonable.
        - Keep it minimal and deterministic.
        - If the repo indicates a web service:
        - If Dockerfile exists: prefer ECS Fargate + ALB (or ECS + public IP) + ECR.
        - If only static assets: prefer S3 + (optional) CloudFront.
        - If clearly serverless: Lambda + API Gateway.
        - If there is no clear deploy target, generate a safe “baseline” infrastructure:
        - S3 bucket for artifacts/static assets
        - IAM role/policy stubs (least privileges)
        - (Optional) DynamoDB table if state-like usage is detected
        - Outputs that prove resources exist

        Validation loop
        - After writing files, run init + validate.
        - If validation fails, edit the Terraform files in-place and rerun validate.
        - Do not stop until validate passes.

        Return format
        - Return AWSTerraformFilesOutput: files=[{{name, content}}, ...]
        """

    async def __aenter__(self) -> "AWSTerraformRepoEngineer":
        await self._fileSystem.connect()
        await self._tf_registry.connect()
        await self._aws_tf.connect()
        return self

    async def __aexit__(self, exc_type, exc_value, traceback):
        # Best-effort cleanup
        try:
            await self._aws_tf.cleanup()
        except Exception:
            pass
        try:
            await self._tf_registry.cleanup()
        except Exception:
            pass
        try:
            await self._fileSystem.cleanup()
        except Exception:
            pass


def _format_input(codebase_path: str, workspace_dir: Path) -> str:
    return f"""
Scan the repository at:
{codebase_path}

Write Terraform output to:
{workspace_dir}

Task:
- Infer the infrastructure needed to run the application.
- Generate Terraform files.
- Run terraform init + terraform validate until validation passes.
- Output the list of files (name + content).
"""


async def create_aws_basis_terraform(
    *,
    codebase_path: str,
    app_id: int,
    output_subdir: str = "ai_basis_tf",
    model: str = "gpt-5.2",
    max_turns: int = 40,
) -> AWSTerraformFilesOutput:
    """
    High-level runner.
    """
    async with AWSTerraformRepoEngineer(
        codebase_path=codebase_path,
        app_id=app_id,
        output_subdir=output_subdir,
        model=model,
        max_turns=max_turns,
    ) as eng:
        result = await Runner.run(
            eng.agent,
            input=_format_input(codebase_path, eng._workspace_dir),
            max_turns=max_turns,
        )
        return result.final_output_as(AWSTerraformFilesOutput)
