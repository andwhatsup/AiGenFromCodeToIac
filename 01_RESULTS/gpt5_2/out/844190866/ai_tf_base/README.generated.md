# Generated Terraform (minimal)

This repository contains a simple Flask web app (calculator) with a Dockerfile and Kubernetes manifests.

To keep the infrastructure minimal and broadly compatible (including LocalStack-style environments),
this Terraform creates a single private S3 bucket intended for build artifacts/static assets.

If you want a full runtime deployment on AWS, the next step would typically be:
- ECR repository for the container image
- ECS Fargate service + ALB (or App Runner)

## Usage

```bash
cd ai_basis_tf
terraform init
terraform validate
terraform apply
```
