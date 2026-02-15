# Terraform (minimal) - ECS Fargate Node app

This repo contains a simple Node.js HTTP server (port 3000) and a Dockerfile.

This Terraform deploys a minimal AWS runtime for it:
- ECS Cluster (Fargate)
- ECS Service + Task Definition
- Application Load Balancer (HTTP :80) -> Target Group -> ECS tasks
- CloudWatch Logs
- Uses **default VPC and subnets** (no custom VPC/NAT)

## Usage

```bash
cd workspace/811891514/ai_basis_tf
terraform init
terraform validate
terraform plan
terraform apply
```

### Container image

By default, `var.container_image` is set to `public.ecr.aws/docker/library/node:16-alpine` (placeholder).
For a real deployment, build and push your app image to ECR and set:

```bash
terraform apply -var='container_image=<account>.dkr.ecr.<region>.amazonaws.com/<repo>:<tag>'
```
