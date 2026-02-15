# Terraform deployment (ECS Fargate + ALB + RDS Postgres)

This repository contains a Go REST API that expects a `PG_DSN` environment variable.
The Terraform in this folder provisions:
- ECR repository
- ECS cluster/service (Fargate)
- Application Load Balancer
- RDS PostgreSQL instance

## Build & push image

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_URL=$(terraform -chdir=workspace/389365839/ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker build -t mehlj-pipeline:latest -f Dockerfile .
docker tag mehlj-pipeline:latest ${REPO_URL}:latest
docker push ${REPO_URL}:latest
```

## Apply

```bash
terraform -chdir=workspace/389365839/ai_basis_tf init
terraform -chdir=workspace/389365839/ai_basis_tf apply
```

Then open the ALB DNS name from `terraform output alb_dns_name`.
