## Terraform (generated)

This Terraform configuration provisions a minimal AWS baseline for the repository.

Detected application: Flask URL shortener (SQLite by default).

Provisioned resources:
- S3 bucket for artifacts/static assets
- IAM role + policy stub (least-privilege example for S3 access)

To run:
```bash
terraform init
terraform validate
terraform plan
```
