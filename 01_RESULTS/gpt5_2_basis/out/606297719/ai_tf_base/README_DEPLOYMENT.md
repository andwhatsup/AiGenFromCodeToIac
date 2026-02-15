# Terraform (minimal) for this repository

This repository is a Prefect 2 example that uses an S3 block for flow storage.

This Terraform creates a minimal S3 bucket suitable for storing Prefect flow code/artifacts.

## Usage

```bash
cd ai_basis_tf
terraform init
terraform apply
```

Optionally set a fixed bucket name:

```hcl
# terraform.tfvars
s3_bucket_name = "my-unique-prefect-bucket-name"
```
