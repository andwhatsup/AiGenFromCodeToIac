# Evaluation Module

Validates Terraform code through static analysis and live execution in LocalStack.

## Function: `evaluate_dir()`

```python
evaluate_dir(tf_dir: str, output_dir: str) -> dict
```

**Parameters**:
- `tf_dir` - Directory containing Terraform files to evaluate
- `output_dir` - Output directory for artifacts and reports

**Returns**: Dictionary with evaluation results:
```json
{
  "ok": true,
  "validation": {"pass": true},
  "plan": {"pass": true, "changes": 5},
  "apply": {"pass": true, "deployed_resources": 5},
  "error_details": {},
  "artifacts": {
    "fmt": "path/to/fmt.json",
    "tflint": "path/to/tflint.json",
    "plan": "path/to/plan.json"
  }
}
```

## Evaluation Pipeline

1. **Format Verification** - Checks `terraform fmt`, versions, dependency graph
2. **Static Analysis** - Runs tflint and checkov for linting/policy checks
3. **Terraform Validate** - Validates Terraform syntax and provider requirements
4. **Plan** - Generates execution plan in LocalStack
5. **Apply** - Deploys infrastructure in LocalStack
6. **Cleanup** - Stops LocalStack and archives artifacts

## Files

- **evaluation.py** - Main orchestrator; runs full evaluation pipeline and generates report
- **eval_workflow/format_verification.py** - Checks formatting, Terraform version, dependency graph
- **eval_workflow/schema_checking.py** - Runs tflint (linting) and checkov (policy checks)
- **eval_workflow/live_deployment.py** - Executes terraform validate, plan, apply in LocalStack
- **eval_workflow/replace_lambda.py** - Replaces Lambda functions with dummy implementations for testing
- **eval_workflow/common.py** - Shared utilities (subprocess runners, logging)
- **eval_workflow/override_*.tf** - Terraform override files for provider/Lambda configuration

## Output Artifacts

- `validation.json` - terraform validate results
- `tflint.json` - linting report
- `checkov.json` - policy compliance report
- `plan.json` - terraform plan output
- `apply.log` - terraform apply execution log
- `final_report.json` - summary of all evaluation stages

## Integration

- Runs after IaC generation (both simple and full pipelines)
- LocalStack provides isolated AWS environment for testing
- Failures captured and passed to Code Review Agent for fixes
- Results logged to progress tracking and evaluation directories
