# Terraform deployment (generated)

This repo contains a Go REST API that listens on port 80 and uses Postgres via the `PG_DSN` environment variable.

This Terraform deploys a minimal AWS setup:
- ECR repository for the container image
- ECS Fargate service behind an ALB
- RDS Postgres instance in the default VPC

## Prereqs
- AWS credentials configured (env vars, shared config, etc.)
- Terraform >= 1.5

## Deploy
1) Set DB password (required):

```bash
export TF_VAR_db_password='change-me-please'
```

2) Init/plan/apply:

```bash
cd ai_basis_tf
terraform init
terraform apply
```

3) Build and push the container image to ECR (example):

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_URL=$(terraform -chdir=ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker build -t ${REPO_URL}:latest .
docker push ${REPO_URL}:latest
```

4) Access the API:

```bash
ALB=$(terraform -chdir=ai_basis_tf output -raw alb_dns_name)
curl http://${ALB}/
```
