# Generated Terraform (minimal)

This Terraform deploys the Strapi application as a container on **ECS Fargate** behind an **Application Load Balancer** using the **default VPC**.

## What you must provide

- `container_image`: a public image (Docker Hub) or an ECR image URI.
- Strapi secrets (APP_KEYS, JWT secrets, DB credentials, etc.) should be injected via Secrets Manager/SSM in real deployments. This minimal setup only passes HOST/PORT by default.

## Run

```bash
terraform init
terraform validate
terraform plan -var='container_image=camillehe1992/strapi:latest'
```
