# Terraform deployment (minimal)

This Terraform deploys a minimal ECS Fargate service in the default VPC.

## Notes
- The repository contains a Rust Axum web server listening on port `3000`.
- For a real deployment, build the Docker image and push to ECR, then set `container_image`.

## Commands
```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
terraform apply
```
