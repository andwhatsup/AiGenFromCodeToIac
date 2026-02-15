# ai_basis_tf

Minimal AWS Terraform configuration inferred from the repository.

This repository is an Infrastructure-as-Code starter kit (Terraform + Terragrunt). The minimal AWS infrastructure commonly required to support it is:

- An S3 bucket for Terraform remote state
- A DynamoDB table for Terraform state locking

This Terraform code creates those resources (optionally) and outputs their names.

## Usage

```bash
terraform init
terraform validate
terraform plan
```

Override the bucket name if you need a globally-unique value:

```bash
terraform plan -var='state_bucket_name=my-unique-bucket-name'
```
