# ai_basis_tf

Minimal AWS infrastructure inferred from the repository:

- A Python Lambda function (`lambda/src/lambda_function.py`) that invokes a SageMaker endpoint.
- An EventBridge schedule to trigger the Lambda periodically.
- An S3 bucket to store artifacts/snapshots (optional but useful baseline).

This Terraform does **not** create the SageMaker endpoint/model itself (the repo indicates it already exists / is managed separately). Update `var.sagemaker_endpoint_name` if needed.
