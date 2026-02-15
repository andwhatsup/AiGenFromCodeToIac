# Generated Terraform (minimal)

This repository contains a simple Flask calculator app (see `app.py`) and a `Dockerfile`.
A Kubernetes `deployment.yaml`/`service.yaml` exists, but to keep AWS infrastructure minimal and broadly compatible, this Terraform deploys the container to **ECS Fargate** behind an **Application Load Balancer** using the **default VPC**.

## What it creates
- ECS Cluster, Task Definition, Service (Fargate)
- ALB + Listener + Target Group
- Security groups
- CloudWatch Log Group
- IAM execution role for ECS tasks

## Inputs
- `container_image` defaults to `yash5090/py-calc-app:latest` (from the repo manifest). You can override to your own ECR image.

## Run
```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
```
