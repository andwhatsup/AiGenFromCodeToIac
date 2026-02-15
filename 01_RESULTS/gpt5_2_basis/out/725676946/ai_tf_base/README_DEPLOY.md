# Terraform deployment (ECS Fargate + ALB)

This repository contains a simple Flask app (listens on port 5000). The Terraform in this folder provisions:
- ECR repository for the container image
- ECS cluster + Fargate service
- Application Load Balancer (HTTP/80) forwarding to the service

## Build & push image

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_NAME=flask-hello-world

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker build -t ${REPO_NAME}:latest ..
docker tag ${REPO_NAME}:latest ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:latest

docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:latest
```

Then apply Terraform and open the `alb_dns_name` output.
