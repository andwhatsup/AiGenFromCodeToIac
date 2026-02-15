# Terraform (minimal) for Go webapp on ECS Fargate

This repository contains a simple Go HTTP server listening on port 8080 (see `main.go`) and a `Dockerfile`.

This Terraform creates:
- ECR repository (push your image)
- ECS cluster + Fargate service
- Application Load Balancer (HTTP :80) forwarding to the service on :8080
- CloudWatch log group

## Build & push image

After `terraform apply`, push an image to the created ECR repo:

```bash
AWS_REGION=us-east-1
REPO_URL=$(terraform -chdir=workspace/715498026/ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPO_URL

docker build -t go-webapp .
docker tag go-webapp:latest $REPO_URL:latest
docker push $REPO_URL:latest
```

Then update the service (force new deployment) e.g.:

```bash
aws ecs update-service --cluster go-webapp --service go-webapp --force-new-deployment
```

## Access

```bash
terraform -chdir=workspace/715498026/ai_basis_tf output -raw service_url
```
