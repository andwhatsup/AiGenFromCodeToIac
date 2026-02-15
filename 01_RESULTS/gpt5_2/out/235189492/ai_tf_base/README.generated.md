## Generated Terraform (minimal)

This Terraform deploys:
- An **iterator Lambda** (Node.js) that asynchronously invokes your target Lambda.
- A **Step Functions state machine** that calls the iterator Lambda, waits `interval_seconds`, and repeats `invocations_per_execution` times.

### Inputs
- `target_lambda_arn` (required): ARN of the Lambda you want to invoke.
- `interval_seconds` (default 10)
- `invocations_per_execution` (default 6)

### Run
```bash
cd ai_basis_tf
terraform init
terraform apply -var='target_lambda_arn=arn:aws:lambda:REGION:ACCOUNT:function:NAME'
```

Then start an execution of the state machine (console/CLI) to begin the loop.
