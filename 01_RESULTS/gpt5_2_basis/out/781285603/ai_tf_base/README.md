# Terraform (minimal) - Energi DevOps Challenge

This Terraform creates the IAM resources requested in the repository's DevOps challenge (question 6):

- IAM Role (no permissions) assumable by principals in the same AWS account
- IAM Policy allowing `sts:AssumeRole` on that role
- IAM Group with the policy attached
- IAM User in that group

## Variables
- `aws_region` (default: `us-east-1`)
- `app_name` (default: `energi-node`)
- `name_suffix` (default: empty)

Example:
```bash
terraform init
terraform apply -auto-approve \
  -var='app_name=prod-ci' \
  -var='name_suffix='
```
