# Terraform deployment (ECS Fargate)

This repo contains a simple Node/Express app listening on port 3000.

## What this Terraform creates
- ECR repository for the container image
- ECS cluster + Fargate service (public IP)
- CloudWatch log group
- Security group allowing inbound `3000/tcp`

## Build & push image
```bash
export AWS_REGION=us-east-1
export APP_NAME=hello-world

# Get repo URL from terraform output
REPO_URL=$(terraform -chdir=workspace/815088170/ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $(echo $REPO_URL | cut -d/ -f1)

docker build -t $REPO_URL:latest -f dockerfile .
docker push $REPO_URL:latest
```

After pushing, ECS will pull `:latest`.

## Notes
This is a minimal setup (no ALB). The task is reachable via its public IP on port 3000.
To discover the task ENI/public IP, use the ECS console or `aws ecs describe-tasks`.
