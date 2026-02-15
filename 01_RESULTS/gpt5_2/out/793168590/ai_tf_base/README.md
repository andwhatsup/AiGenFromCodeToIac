## Terraform (minimal)

This Terraform deploys the minimal AWS infrastructure inferred from the repository:

- A Lambda function (packaged from `../lambda/src/lambda_function.py`) that invokes a SageMaker endpoint.
- An EventBridge schedule to trigger the Lambda.
- An S3 bucket for artifacts.

### Usage

```bash
cd ai_basis_tf
terraform init
terraform validate
terraform apply
```

Variables:
- `aws_region` (default: eu-west-1)
- `sagemaker_endpoint_name` (default: hello-world-endpoint)
- `lambda_schedule_expression` (default: rate(1 hour))
