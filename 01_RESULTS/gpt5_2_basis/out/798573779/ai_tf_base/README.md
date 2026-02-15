# Terraform (minimal) for this repository

This repo contains a simple Nginx container (see `Dockerfile`) that serves `index.html` and images.

This Terraform configuration intentionally provisions a minimal baseline that is easy to `terraform init` + `terraform validate`:

- **ECR repository**: where CodeBuild/your CI can push the built Docker image.
- **S3 bucket**: a generic artifacts bucket (useful for CodePipeline/CodeBuild artifacts or static assets).

It does **not** create ECS/ALB/CodePipeline resources to keep the footprint minimal and validation-friendly.

## Usage

```bash
cd workspace/798573779/ai_basis_tf
terraform init
terraform validate
terraform plan
```
