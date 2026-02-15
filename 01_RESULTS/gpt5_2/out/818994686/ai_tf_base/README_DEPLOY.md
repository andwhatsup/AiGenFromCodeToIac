# Terraform (minimal) - App Runner + ECR

This repository contains a NestJS API packaged as a Docker image (see `Dockerfile`) and a CI workflow that deploys to **AWS App Runner** from **ECR**.

This Terraform creates:
- An ECR repository
- An IAM role for App Runner to pull from ECR
- An App Runner service that runs the container

## Deploy flow
1. `terraform apply`
2. Build & push image to the created ECR repo (tag `latest` by default)
3. App Runner will auto-deploy when a new image is pushed.

Variables:
- `image_tag` (default `latest`)
- `aws_region` (default `us-east-2`)
