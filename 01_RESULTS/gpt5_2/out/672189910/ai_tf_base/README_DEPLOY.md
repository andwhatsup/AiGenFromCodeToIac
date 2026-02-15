# Terraform (minimal) for llm-documentation

This repository contains a Streamlit app (see root `Dockerfile`, port 8050).

This Terraform creates minimal AWS primitives to support deployment:
- **ECR repository**: push the container image
- **S3 bucket**: store artifacts/static assets

## Build & push image (example)

```bash
AWS_REGION=us-west-2
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_URL=$(terraform -chdir=workspace/672189910/ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker build -t llm-documentation:latest .
docker tag llm-documentation:latest $REPO_URL:latest
docker push $REPO_URL:latest
```

From here you can run it on ECS/Fargate or another container runtime.
This project intentionally keeps infra minimal to ensure `terraform validate` succeeds
in conservative environments.
