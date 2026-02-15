# Terraform deployment (generated)

This Terraform deploys:
- S3 bucket (private) used by the Lambda function
- IAM role/policy for Lambda (CloudWatch Logs + S3 list/get)
- Lambda function from `../lambda_function.zip`
- API Gateway v2 HTTP API with routes:
  - `GET /list-bucket-content`
  - `GET /list-bucket-content/{folder+}`

## Usage

```bash
cd ai_basis_tf
terraform init
terraform apply
```

If S3 bucket name collision occurs, set `bucket_name`:

```bash
terraform apply -var='bucket_name=my-unique-bucket-name'
```
