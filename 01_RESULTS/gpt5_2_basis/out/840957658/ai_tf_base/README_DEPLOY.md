# Terraform deployment (ECS Fargate + ALB)

This repo contains a Spring Boot app packaged as a Docker image (see `Dockerfile`, port 8080).

## What Terraform creates
- ECR repository to store the image
- ECS cluster + Fargate service
- Application Load Balancer (HTTP/80) forwarding to the service
- CloudWatch log group

## Build & push image
```bash
AWS_REGION=us-east-1
APP_NAME=helloapp

# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $(terraform -chdir=ai_basis_tf output -raw ecr_repository_url | cut -d/ -f1)

# Build and push
docker build -t $APP_NAME:latest .
docker tag $APP_NAME:latest $(terraform -chdir=ai_basis_tf output -raw ecr_repository_url):latest
docker push $(terraform -chdir=ai_basis_tf output -raw ecr_repository_url):latest
```

Then apply Terraform (or re-deploy service) if you change `image_tag`.
