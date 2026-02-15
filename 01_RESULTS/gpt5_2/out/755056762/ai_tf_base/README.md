# Terraform (minimal)

This Terraform creates the minimal AWS infrastructure inferred from the repository:

- An S3 bucket (private) to receive ingested data.

## Usage

```bash
terraform init
terraform validate
terraform apply
```

Outputs include the bucket name/ARN.
