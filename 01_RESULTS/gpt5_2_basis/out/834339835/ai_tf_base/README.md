# Terraform (minimal) for loan-calc

This repository contains a static HTML/CSS/JS loan calculator and a Dockerfile that serves the content via nginx.

To keep the infrastructure minimal and broadly compatible, this Terraform creates an S3 bucket intended for storing build artifacts/static assets.

## Usage

```bash
terraform init
terraform validate
terraform apply
```
