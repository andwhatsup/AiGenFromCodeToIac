# Terraform deployment (ECS Fargate)

This Terraform creates minimal AWS infrastructure to run the Node.js HTTP server in this repo on **ECS Fargate**.

## What it creates
- ECR repository for the container image
- ECS cluster, task definition, and service (Fargate)
- CloudWatch log group
- Security group allowing inbound traffic to the container port (default 3000)

## Build & push image
After `terraform apply`, push an image tagged `latest`:

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_URL=$(terraform -chdir=ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker build -t node-hello:latest .
docker tag node-hello:latest ${REPO_URL}:latest
docker push ${REPO_URL}:latest
```

Then the ECS service will pull the image.
