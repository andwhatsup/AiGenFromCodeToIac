# ai_basis_tf

Terraform configuration generated for this repository.

This repo is a LocalStack + Terratest example; the minimal infrastructure required is an S3 bucket.

Defaults are set to work with LocalStack running at `http://localhost:4566`.

## Commands

```bash
cd workspace/782556535/ai_basis_tf
terraform init
terraform validate
```

To use real AWS, set `aws_endpoint_url` to an empty string and disable the skip flags.
