# Terraform deployment (ECS Fargate + ALB)

This Terraform creates minimal AWS infrastructure to run the Node.js container:
- ECR repository
- ECS cluster + Fargate service
- Application Load Balancer (HTTP :80)
- CloudWatch log group

## Build & push image

1. Authenticate to ECR
2. Build and push `:latest` to the created repository URL (see output `ecr_repository_url`).

## Deploy

```bash
cd workspace/812259532/ai_basis_tf
terraform init
terraform apply
```

Then open the `alb_dns_name` output in a browser.
