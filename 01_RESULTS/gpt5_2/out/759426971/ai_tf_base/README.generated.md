# Generated Terraform (LocalStack)

This repository is a LocalStack demo. The minimal infrastructure to validate and test against LocalStack is:

- S3 bucket (artifacts)
- DynamoDB table

## Usage

```bash
cd ai_basis_tf
terraform init
terraform validate
terraform apply -auto-approve
```

LocalStack defaults are already configured in `provider.tf`.
