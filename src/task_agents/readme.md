# Task Agents Module

Multi-agent system for analyzing source code and generating AWS infrastructure-as-code.

## Agent Overview

| Agent | Purpose | Model | Temp | MCPs |
|-------|---------|-------|------|------|
| **Source Analyzer** | Parse codebase structure, languages, frameworks, deployment files | gpt-5.2 | 0.0 | Filesystem |
| **Architecture Creator** | Design system architecture and create PlantUML diagrams | gpt-5.2 | 0.0 | PlantUML validator |
| **AWS Cloud Architect** | Map architecture to AWS services and resources | gpt-5.2 | 0.0 | Web Search |
| **AWS Terraform Engineer** | Full: Generate complete Terraform files (multi-agent approach) | gpt-5.2 | 0.0 | Filesystem, Terraform, AWS |
| **AWS Terraform Basis Engineer** | Simple: Generate minimal Terraform files (single-agent approach) | gpt-5.2 | 0.0 | Filesystem, Terraform, AWS |
| **Code Review Agent** | Fix Terraform errors iteratively after evaluation failures | gpt-5.2 | 0.0 | Filesystem, Terraform |

## Configurations

**Common Settings**:
- Temperature: 0.0 (deterministic, no randomness)
- Model: gpt-5.2 (default for all agents)
- Output: Structured Pydantic models

**MCP Servers**:
- **Filesystem**: Read/write access to codebase and workspace directories
- **Terraform Registry**: Terraform provider/module documentation lookups
- **AWS**: AWS resource and best practices reference
- **Web Search**: External documentation and examples

## Pipeline Execution

**Full Multi-Agent Chain** (task_agents):

```
Source Analyzer
     ↓ SourceAnalyzerOutput
Architecture Creator
     ↓ ArchitectureCreatorOutput
AWS Cloud Architect
     ↓ AWSCloudArchitectureCreatorOutput
AWS Terraform Engineer
     ↓ AWSTerraformFilesOutput
→ Evaluation & fixes via Code Review Agent
```

**Simple Single-Agent** (basis):

```
AWS Terraform Basis Engineer (scans repo directly)
     ↓ AWSTerraformFilesOutput
→ Evaluation & fixes via Code Review Agent
```

## Files

- **source_analyzer.py** - Analyzes codebase structure (languages, frameworks, dependencies)
- **architecture_creator.py** - Designs system architecture with PlantUML diagrams
- **aws_cloud_architecture_creator.py** - Maps architecture to AWS services
- **aws_terraform_engineer.py** - Generates full Terraform (multi-agent chain)
- **aws_terraform_basis_engineer.py** - Generates minimal Terraform (single-agent, fast)
- **code_review_agent.py** - Fixes Terraform errors from evaluation feedback
- **multi-agent-prompts.yml** - Prompt templates for multi-agent approach
- **single-agent-prompt.yml** - Prompt template for single-agent basis approach

## Output Models

**SourceAnalyzerOutput**: projects (languages, frameworks, dependencies, files)

**ArchitectureCreatorOutput**: plantuml_diagram, svg_diagram, description

**AWSCloudArchitectureCreatorOutput**: aws_architecture_description, aws_resources list

**AWSTerraformFilesOutput**: files (name, content pairs)

**CodeReviewResult**: fixed (bool), changes_made (list)

## Integration

- Called from main.py pipeline
- Agents run async with ModelSettings for consistency
- Output cached in log/{app_id}/agent_log/ during development
- Errors trigger Code Review Agent for iterative fixes
