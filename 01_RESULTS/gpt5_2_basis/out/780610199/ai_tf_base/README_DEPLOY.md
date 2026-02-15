# Terraform deployment (ECS Fargate + ALB)

This repo contains a simple Node.js HTTP server listening on port 3000 (see `index.js`) and a `Dockerfile`.

Terraform provisions:
- ECR repository for the image
- ECS cluster + Fargate service
- Application Load Balancer (HTTP :80) forwarding to the service

## Build & push image

1. Authenticate to ECR
2. Build and push `:latest` to the output `ecr_repository_url`

## Apply

```bash
cd workspace/780610199/ai_basis_tf
terraform init
terraform apply
```

Then open the `alb_dns_name` output in a browser.
