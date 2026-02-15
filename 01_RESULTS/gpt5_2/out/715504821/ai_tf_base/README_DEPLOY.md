# Deployment notes

This repository contains a minimal FastAPI app (see `tla_example/src/main.py`) and a `Dockerfile` that runs Uvicorn on port 8080.

This Terraform deploys:
- ECR repository (push your image)
- ECS Fargate service
- Application Load Balancer (HTTP :80)
- CloudWatch Logs

## Build & push image

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_URL=$(terraform -chdir=workspace/715504821/ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker build -t tla-example:latest /ai-code-generation-from-code-to-iac/workspace/715504821

docker tag tla-example:latest ${REPO_URL}:latest

docker push ${REPO_URL}:latest
```

Then (re)deploy the service if needed:

```bash
terraform -chdir=workspace/715504821/ai_basis_tf apply
```

Open the ALB URL:

```bash
echo "http://$(terraform -chdir=workspace/715504821/ai_basis_tf output -raw alb_dns_name)/"
```
