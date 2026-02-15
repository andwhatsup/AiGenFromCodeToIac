# Terraform deployment (minimal)

This Terraform creates a minimal AWS deployment for the NestJS API in this repo:

- ECR repository (push your Docker image)
- ECS Fargate service behind an ALB
- RDS MySQL instance (private)

## Build & push image

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_URL=$(terraform -chdir=ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker build -t api:latest .
docker tag api:latest ${REPO_URL}:latest
docker push ${REPO_URL}:latest
```

## Apply

```bash
terraform -chdir=ai_basis_tf init
terraform -chdir=ai_basis_tf apply
```

Then open the ALB URL:

```bash
terraform -chdir=ai_basis_tf output -raw alb_dns_name
```
