from agents import Agent, ModelSettings, Runner
from agents.extensions.handoff_prompt import RECOMMENDED_PROMPT_PREFIX
from agents.mcp import MCPServerStdio
from pydantic import BaseModel
from pathlib import Path

from task_agents.architecture_creator import ArchitectureCreatorOutput
from task_agents.aws_cloud_architecture_creator import AWSCloudArchitectureCreatorOutput
from task_agents.source_analyzer import SourceAnalyzerOutput


class AWSTerraformFile(BaseModel):
    name: str
    content: str


class AWSTerraformFilesOutput(BaseModel):
    files: list[AWSTerraformFile]


class AWSTerraformEngineer:
    def __init__(self, codebase_path: str, app_id: int):
        self._codebase_path = codebase_path

        # Create workspace directory before initializing filesystem
        workspace_dir = Path(f"./workspace/{app_id}/ai_tf")
        workspace_dir.mkdir(parents=True, exist_ok=True)

        self._fileSystem = MCPServerStdio(
            name="Filesystem",
            params={
                "command": "npx",
                "args": [
                    "-y",
                    "@modelcontextprotocol/server-filesystem",
                    self._codebase_path,
                    str(workspace_dir),
                ],
            },
            client_session_timeout_seconds=300,
        )
        self._tf = MCPServerStdio(
            name="Terraform Registry",
            params={
                "command": "docker",
                "args": ["run", "-i", "--rm", "hashicorp/terraform-mcp-server:latest"],
            },
            client_session_timeout_seconds=60,
        )
        self._aws = MCPServerStdio(
            name="AWS Terraform",
            params={
                "command": "uvx",
                "args": [
                    "awslabs.terraform-mcp-server@latest",
                ],
                "env": {
                    "FASTMCP_LOG_LEVEL": "ERROR",
                },
            },
            client_session_timeout_seconds=60,
        )

        self.agent = Agent(
            name="AWS Terraform Engineer",
            model="gpt-5.2",
            model_settings=ModelSettings(
                temperature=0.0,
            ),
            handoff_description="""
            Specialist agent that generates Terraform configuration files for AWS cloud infrastructure based on codebase, architecture, and AWS resource analysis.
            """,
            instructions=f"""{RECOMMENDED_PROMPT_PREFIX}

            You are an expert Terraform developer specializing in AWS cloud infrastructure.

            Your task is to:
            1. Analyze the provided codebase, architecture, and AWS resource information (including languages, frameworks, dependencies, architectural resources, and AWS resource list).
            2. Generate a set of Terraform configuration files (using .tf and .tfvars as appropriate) that will provision the described AWS infrastructure, following best practices for security, modularity, and maintainability.
            3. For each file, provide a name (e.g., main.tf, variables.tf, outputs.tf, provider.tf, etc.) and its content.
            4. Write each file to the /workspace/<app_id>/ai_tf directory on the local filesystem.
            5. Use the web search tool to look up Terraform AWS documentation or best practices for specific resources or patterns if unsure.
            6. You have access to the source codebase via the Source Filesystem MCP server, which allows you to read any source file as needed to inform your Terraform configuration.

            You have access to the following MCP servers:
            - Filesystem: {self._fileSystem.name} - MCP server for reading the source codebase and writing the output files.
            - Terraform Registry: {self._tf.name} - The Terraform MCP Server is a Model Context Protocol (MCP) server that provides seamless integration with Terraform Registry APIs, enabling advanced automation and interaction capabilities for Infrastructure as Code (IaC) development.
            - AWS Terraform: {self._aws.name} - MCP server for Terraform on AWS best practices, infrastructure as code patterns, and security compliance with Checkov. Also provides Terraform related commands like Initialize, plan, validate, apply, and destroy operations.

            Guidelines:
            - Only include necessary resources and avoid over-engineering.
            - Use Terraform modules and variables where appropriate.
            - Ensure the configuration is secure, scalable, and follows AWS and Terraform best practices.
            - Output a list of files, each with a name and content. All files must be written to the /workspace/<app_id>/ai_tf directory.
            - If you are unsure about the Terraform syntax or best practices for a resource, use the available tools to find the official documentation or examples.
            - Use the AWS MCP server to initialize and then validate the Terraform configuration. Do not use checkov, use Terraform Validate to check if the configuration is correct.
            - The validation is important to ensure the configuration is correct and will be applied successfully.

            Your output must be a VALID list of files, each with a name and content, representing the Terraform configuration for the described AWS infrastructure.
            All files must be written to the /workspace/<app_id>/ai_tf directory.
            The configuration must be valid, initialized, and verified by the AWS MCP server.
            """,
            mcp_servers=[self._fileSystem, self._tf, self._aws],
            tools=[],
            output_type=AWSTerraformFilesOutput,
        )

    async def __aenter__(self) -> "AWSTerraformEngineer":
        print("Initializing AWS Terraform Engineer")
        await self._fileSystem.connect()
        await self._tf.connect()
        await self._aws.connect()
        return self

    async def __aexit__(self, exc_type, exc_value, traceback):
        print("Cleanup AWS Terraform Engineer")
        try:
            await self._aws.cleanup()
            print("AWS cleanup succeeded")
        except Exception as e:
            print(f"AWS cleanup error: {e}")
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


def _format_input(analysis, architecture, aws_architecture, codebase_path):
    return f"""
Codebase Path:
{codebase_path}

Codebase Analysis:
{analysis.model_dump_json()}

Architecture Analysis:
{architecture.model_dump_json()}

AWS Architecture Analysis:
{aws_architecture.model_dump_json()}

Generate the (VALID and INITIALIZED) Terraform configuration files for this system.
Output a list of files, each with a name and content.
All files must be written to the /workspace/<app_id>/ai_tf directory with the MCP filesystem tool.
"""


async def create_aws_terraform(
    analysis: SourceAnalyzerOutput,
    architecture: ArchitectureCreatorOutput,
    aws_architecture: AWSCloudArchitectureCreatorOutput,
    codebase_path: str,
    app_id: int,
) -> AWSTerraformFilesOutput:
    async with (
        AWSTerraformEngineer(codebase_path, app_id) as tf_engineer,
    ):
        result = await Runner.run(
            tf_engineer.agent,
            input=_format_input(
                analysis, architecture, aws_architecture, codebase_path
            ),
            max_turns=30,
        )
        return result.final_output_as(AWSTerraformFilesOutput)
