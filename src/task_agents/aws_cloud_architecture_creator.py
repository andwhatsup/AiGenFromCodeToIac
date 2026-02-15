from agents import Agent, ModelSettings, Runner, WebSearchTool
from agents.extensions.handoff_prompt import RECOMMENDED_PROMPT_PREFIX
from pydantic import BaseModel

from task_agents.architecture_creator import ArchitectureCreatorOutput
from task_agents.source_analyzer import SourceAnalyzerOutput


class AWSCloudArchitectureCreatorOutput(BaseModel):
    """Output model for the Cloud Architecture Creator agent (AWS)."""

    aws_architecture_description: str
    """A detailed description of the proposed AWS architecture in natural language."""
    aws_resources: list[str]
    """A list of AWS resources (e.g., VPC, subnets, EC2, RDS, S3, etc.) to be created."""


class AWSCloudArchitectureCreator:
    def __init__(self):
        self.agent = Agent(
            name="Cloud Architecture Creator (AWS)",
            model="gpt-5.2",
            model_settings=ModelSettings(
                temperature=0.0,
            ),
            handoff_description="""
            Specialist agent that creates AWS cloud deployment architectures and resource lists from codebase and architecture analysis.
            """,
            instructions=f"""{RECOMMENDED_PROMPT_PREFIX}

            You are an expert cloud architect specializing in designing AWS cloud architectures for software systems.

            Your task is to:
            1. Analyze the provided codebase and architecture information (including languages, frameworks, dependencies, and architectural resources).
            2. Propose a high-level AWS architecture for deploying the system, describing the main components, their relationships, and deployment strategies.
            3. Produce a comprehensive list of AWS resources that need to be created, including but not limited to: VPC, subnets, security groups, EC2, RDS, S3, IAM roles, Lambda, API Gateway, etc. Ensure all relevant resources from the codebase and architecture analysis are included, and add any AWS-specific foundational resources (e.g., networking, IAM, monitoring).
            4. Use the web search tool to look up AWS documentation or best practices as needed for specific resource types or deployment patterns.

            Your output must include:
            1. A detailed text description of the proposed AWS architecture.
            2. A list of AWS resources to be provisioned, with each resource type clearly named.

            Guidelines:
            - Ensure the architecture is secure, scalable, and follows AWS best practices.
            - Include all components inferred from the codebase and architecture analysis.
            - Add foundational AWS resources (VPC, subnets, etc.) even if not explicitly mentioned in the input.
            - Use the web search tool to verify AWS resource types or find documentation if unsure.
            - Be explicit and complete in your resource list.
            - Be as lean as possible, only include necessary resources and avoid over-engineering.
            """,
            mcp_servers=[],
            tools=[WebSearchTool()],
            output_type=AWSCloudArchitectureCreatorOutput,
        )

    async def __aenter__(self) -> "AWSCloudArchitectureCreator":
        print("Initializing Cloud Architecture Creator (AWS)")
        return self

    async def __aexit__(self, exc_type, exc_value, traceback):
        print("Cleanup Cloud Architecture Creator (AWS)")


async def create_aws_cloud_architecture(
    analysis: SourceAnalyzerOutput,
    architecture: ArchitectureCreatorOutput,
) -> AWSCloudArchitectureCreatorOutput:
    async with (
        AWSCloudArchitectureCreator() as cloud_arch_creator,
    ):
        result = await Runner.run(
            cloud_arch_creator.agent,
            input=f"""
            The codebase and architecture have been analyzed. Here is the information:

            Codebase Analysis:
            {analysis.model_dump_json()}

            Architecture Analysis:
            {architecture.model_dump_json()}

            Propose a high-level AWS architecture for deploying this system.
            Output the AWS architecture description and a list of AWS resources to be created.
            """,
        )
        return result.final_output_as(AWSCloudArchitectureCreatorOutput)
