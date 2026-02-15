# Analysis Module

Scans repositories to detect application type, tech stack, deployment patterns, and existing Terraform code.

## Function: `analyze_repo()`

```python
analyze_repo(repo_path: str, output_dir: str = None) -> bool
```

**Returns**: `True` if repository contains deployable application code.

**Output**: `gate.json` with analysis metadata:
```json
{
  "deployable": true,
  "app_type": "web_service",
  "tech_stack": ["Node.js", "Express"],
  "deployment_method": "container",
  "terraform_found": true,
  "terraform_health": "valid",
  "recommended_roots": [".", "infrastructure"],
  "deployment_indicators": {
    "dockerfile": true,
    "package_json": true
  }
}
```

## Detection

Identifies:
- **App types**: Web services, APIs, static sites, serverless, CLI tools
- **Tech stacks**: Node.js, Python, Go, Java, Rust via package managers and frameworks
- **Deployment patterns**: Container, serverless, static, traditional VM
- **Terraform**: Existing code location, syntax validation, provider constraints

**Indicators**: Dockerfile, package.json, requirements.txt, docker-compose.yml, go.mod, pom.xml, Cargo.toml, Makefile

## Gate Flags

- `deployable` - Repository contains deployment indicators
- `terraform_found` - Existing Terraform detected
- `terraform_health` - valid/invalid
- `recommended_roots` - Directories recommended for IaC generation
- `deployment_indicators` - Breakdown of detected files

## Files

- **repo_analyzer.py** - Main entry point; orchestrates detection and generates gate.json
- **terraform_scanner.py** - Scans and parses *.tf files; extracts variables, resources, state, provider constraints
- **localstack_checker.py** - Validates AWS resources can run in LocalStack (local testing environment)
- **tfvars_builder.py** - Generates .tfvars files with default/inferred values for Terraform variables
- **__init__.py** - Module exports

## Pipeline Integration

1. Analysis runs after source is fetched
2. Gate flags guide downstream stages
3. `deployable: false` may skip application
4. `recommended_roots` used by Terraform generation
5. `terraform_health` informs evaluation strategy
