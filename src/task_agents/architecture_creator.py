import logging

from agents import Agent, ModelSettings, Runner, function_tool
from agents.extensions.handoff_prompt import RECOMMENDED_PROMPT_PREFIX
from plantweb.render import render
from pydantic import BaseModel
from requests import HTTPError

from task_agents.source_analyzer import SourceAnalyzerOutput


class ArchitectureCreatorOutput(BaseModel):
    """Output model for the Architecture Creator agent."""

    plantuml_diagram: str
    """The PlantUML diagram in syntax format."""
    svg_diagram: str
    """The SVG diagram as a string."""
    architecture_description: str
    """A detailed description of the architecture in natural language."""


@function_tool
def validate_plantuml_and_convert_to_svg(plantuml_code: str) -> str:
    """
    Validate the PlantUML code and convert it to SVG.

    Args:
        plantuml_code: The PlantUML code to validate and convert.

    Returns:
        The SVG diagram as a string, or an error message (prepended with "Error: ")
        if the PlantUML code is invalid.
    """
    try:
        (svg, _, _, _) = render(
            plantuml_code,
            engine="plantuml",
            format="svg",
            cacheopts={"use_cache": False},
        )
        logging.getLogger("openai.agents").debug(f"SVG created: {svg}")
        return svg.decode("utf-8")
    except HTTPError as e:
        headers = e.response.headers
        description = headers.get("x-plantuml-diagram-description")
        error = headers.get("x-plantuml-diagram-error")
        error_line = headers.get("x-plantuml-diagram-error-line")
        msg = f"Error: line={error_line} | {description} :: {error}"
        logging.getLogger("openai.agents").error(f"ERROR DIAGRAM: Error on line {error_line}: {description}\n{error}\n{plantuml_code}")

        return msg # return the error message


class ArchitectureCreator:
    def __init__(self):
        self.agent = Agent(
            name="Architecture Creator",
            model="gpt-5.2",
            model_settings=ModelSettings(
                temperature=0.0,
            ),
            handoff_description="""
            Specialist agent that creates abstract software architecture (and corresponding SVG diagrams) from given codebase information
            like programming languages, frameworks, dependencies and required architectural resources.
            """,
            instructions=f"""{RECOMMENDED_PROMPT_PREFIX}

            You are an expert software architect specializing in creating high-level deployment architectures based on codebase analysis.

            Your task is to:
            1. Analyze the provided codebase information (languages, frameworks, dependencies, and required resources)
            2. Create a high-level software architecture that represents the target deployment
            3. Generate a PlantUML deployment diagram that visualizes this architecture
            4. Validate and Convert the PlantUML diagram to SVG format (use the provided tool to do this)

            Guidelines for the architecture:
            - Focus on block-level components (e.g., API, Database, Storage, WebApp)
            - Include programming languages and frameworks for each component
            - Show clear relationships and dependencies between components
            - Ensure the architecture reflects all required resources from the codebase analysis
            - Keep the diagram clean and readable at a high level
            
            PlantUML header rules (mandatory):
            - Do NOT use !includeurl.
            - After @startuml, add exactly:
            !define AWSPuml https://raw.githubusercontent.com/awslabs/aws-icons-for-plantuml/v20.0/dist
            !include AWSPuml/AWSCommon.puml
            - Never place include paths/URLs in stereotypes or labels (e.g., NEVER «AWSPuml/.../AmazonS3»).

            Your output must include:
            1. A detailed PlantUML deployment diagram in syntax format
            2. A valid SVG representation of the diagram
            3. A clear description of the architecture explaining the components and their relationships

            Remember to:
            - Use proper PlantUML deployment diagram syntax
            - Include all necessary components from the codebase analysis
            - Label components with their technologies and frameworks
            - Show clear deployment relationships between components
            - Keep the architecture abstract but complete
            - If the tool result starts with "Error:", analyze the error text (line number, description), fix the PlantUML (!include lines, syntax, macros), and call the tool again.
            - Repeat until the tool returns an SVG (string starts with "<svg"). Only then finalize output.
            """,
            mcp_servers=[],  # No filesystem MCP server required
            tools=[validate_plantuml_and_convert_to_svg],
            output_type=ArchitectureCreatorOutput,
        )

    async def __aenter__(self) -> "ArchitectureCreator":
        print("Initializing Architecture Creator")
        # No connect needed
        return self

    async def __aexit__(self, exc_type, exc_value, traceback):
        print("Cleanup Architecture Creator")
        # No cleanup needed


async def create_architecture(
    analysis: SourceAnalyzerOutput,
) -> ArchitectureCreatorOutput:
    async with (
        ArchitectureCreator() as arch_creator,
    ):
        # turn off svg representation with adding the comment, as string., after svg representation
        result = await Runner.run(
            arch_creator.agent,
            max_turns=25,
            input=f"""
            The codebase has been analyzed and the following information is available:
            {analysis.model_dump_json()}

            Create a high level architecture for the codebase.
            Output the architecture description, the plantuml diagram and the svg representation.
            """,
        )
        return result.final_output_as(ArchitectureCreatorOutput)