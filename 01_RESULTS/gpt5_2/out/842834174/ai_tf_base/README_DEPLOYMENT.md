# Terraform (minimal) deployment

This repository contains a static site (index.html/style.css/script.js) and a Dockerfile that serves the content via nginx.

This Terraform configuration intentionally provisions a minimal, conservative AWS baseline that validates reliably:

- An S3 bucket for artifacts/static assets (private, versioned, encrypted)

You can extend this later to:
- S3 static website hosting + CloudFront
- ECS Fargate service behind an ALB (serving the nginx container)

## Usage

```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
terraform apply
```
