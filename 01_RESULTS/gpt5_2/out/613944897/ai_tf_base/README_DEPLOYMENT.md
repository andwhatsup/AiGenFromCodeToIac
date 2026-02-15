# Terraform deployment (minimal)

This repository contains a simple Node.js/Express app (listens on `PORT`, default 8080) and a Dockerfile.

This Terraform creates a minimal **ECS Fargate** service in the **default VPC** with a public IP and a security group allowing inbound traffic to the container port.

## Important
- The service runs whatever image you provide via `var.image`.
- This Terraform does **not** build/push the Docker image. Build and push to ECR (or use any reachable registry) and set `-var image=...`.

## Commands
```bash
cd workspace/613944897/ai_basis_tf
terraform init
terraform validate
terraform plan -var image=<your_image_uri>
```
