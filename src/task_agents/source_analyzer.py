from agents import Agent, ModelSettings, Runner
from agents.extensions.handoff_prompt import RECOMMENDED_PROMPT_PREFIX
from agents.mcp import MCPServerStdio
from pydantic import BaseModel

class Project(BaseModel):
    project_directory: str
    programming_languages: list[str]
    frameworks: list[str]
    dependencies: list[str]
    deployment_relevant_files: list[str]
    architectural_resources: list[str]


class SourceAnalyzerOutput(BaseModel):
    projects: list[Project]


class SourceAnalyzer:
    def __init__(self, codebase_path: str):
        self._codebase_path = codebase_path
        self._filesystem = MCPServerStdio(
            name="CodeBase Filesystem",
            params={
                "command": "npx",
                "args": [
                    "-y",
                    "@modelcontextprotocol/server-filesystem",
                    self._codebase_path,
                ],
            },
            client_session_timeout_seconds=60,
        )
        self.agent = Agent(
            name="Source Analyzer",
            model="gpt-5.2",
            model_settings=ModelSettings(
                temperature=0.0,
            ),
            handoff_description="""
            Specialist agent that analyzes source code and provides a detailed description of the code base.
            """,
            instructions=f"""{RECOMMENDED_PROMPT_PREFIX}

            You are a Source Code Analyzer agent...

            You have access to a filesystem MCP server with tools including:
            - list_directory(path)
            - search_files(path, pattern, excludePatterns)
            - directory_tree(path, excludePatterns)
            - read_text_file(path), read_multiple_files(paths), get_file_info(path), etc.

            IMPORTANT:
            - Use `directory_tree` or `search_files` to explore subdirectories recursively.
            - Start from "." (the repository root) and recursively discover all relevant files.
            - Do not rely solely on `list_directory` at the root; that only shows immediate children.

            PREFERRED STRATEGY:
            1. Call `directory_tree` with path "." and appropriate excludePatterns (node_modules, .git, etc.).
            2. From that tree, identify:
            - project directories (backend, frontend, api, etc.)
            - dependency/config files and deployment-related files.
            3. For specific file types (e.g. requirements.txt, package.json, pyproject.toml, Dockerfile),
            either inspect the tree or call `search_files` with a matching pattern.
            4. Then read and analyze only the relevant files using `read_text_file` or `read_multiple_files`.

            ANALYSIS OBJECTIVES:

            For each detected project (for example, "backend", "frontend", "api", "worker"),
            do the following:

            1. Determine the primary programming language(s) used in the project.
               If multiple folders contain separate applications (e.g. "backend" and "frontend"),
               treat them as separate projects.

            2. Identify the main framework(s) or libraries in use
               (e.g., Flask, Django, FastAPI, Express, Next.js, React, Angular, Spring Boot, etc.).

            3. With the knowledge of the programming language and the used framework,
               list all detected dependencies, referencing configuration or dependency files
               where possible (e.g., requirements.txt, pyproject.toml, package.json, go.mod, *.csproj).

            4. Assess whether any dependencies or code patterns imply the need for
               specific cloud resources (such as databases, storage buckets, message queues, caches,
               authentication providers, third-party APIs, etc.).
               Also list the project itself as a cloud resource (e.g. API or web application).

            5. For each project: summarize your findings in a clear, structured format, including:
               - project_directory: relative path of the project root
               - programming_languages: list of languages used
               - frameworks: list of frameworks/libraries used
               - dependencies: list of significant dependencies and where they were found
               - deployment_relevant_files: list of files and their paths
                 (e.g. Dockerfile, docker-compose.yml, k8s manifests, Makefile)
               - architectural_resources: inferred cloud / infrastructure resources

            IMPORTANT BEHAVIORAL RULES:

            - Always traverse directories recursively until you have a complete picture of the repo.
              Do not restrict yourself to the top-level files.
            - Prefer reading configuration and dependency files before individual source files.
            - Be explicit about which files and paths you used as evidence for your conclusions.
            - Be concise but complete: do not omit a project just because it is in a subdirectory.

            Your output MUST be a valid JSON object that matches the `SourceAnalyzerOutput` schema.
            """,
            mcp_servers=[self._filesystem],
            output_type=SourceAnalyzerOutput,
        )

    async def __aenter__(self) -> "SourceAnalyzer":
        print("Initializing Source Analyzer")
        await self._filesystem.connect()
        return self

    async def __aexit__(self, exc_type, exc_value, traceback):
        print("Cleanup Source Analyzer")
        await self._filesystem.cleanup()


async def analyze_codebase(codebase_path: str) -> SourceAnalyzerOutput:
    async with SourceAnalyzer(codebase_path) as source_analyzer:
        result = await Runner.run(
            source_analyzer.agent,
            max_turns=40,
            input=f"""
            You are connected to the codebase via a filesystem MCP server whose root is:
            {codebase_path}

            IMPORTANT: You must recursively explore **all** subdirectories starting at the
            filesystem root ("/" or ".") and analyze the entire repository, not just the top-level
            directory.

            After fully exploring the repository, output the codebase analysis.
            """,
        )

        # DEBUG: see what the model actually produced
        print("RAW FINAL OUTPUT:", result.final_output)

        # Then parse into your schema
        return result.final_output_as(SourceAnalyzerOutput)