# Terraform deployment (ECS Fargate + ALB)

This repository contains a simple Node/Express app listening on port 3000.
The Terraform in this folder provisions minimal AWS infrastructure to run it on ECS Fargate behind an Application Load Balancer.

## What gets created
- ECR repository for the container image
- ECS cluster, task definition, and service (Fargate)
- Application Load Balancer + target group + listener
- CloudWatch log group

## Deploy steps (manual image build/push)
1. `terraform init && terraform apply`
2. Build and push the image to ECR (tag `latest`), then force a new deployment.

Example (replace region/account as needed):
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com

docker build -t hello-node:latest ..
docker tag hello-node:latest <account>.dkr.ecr.us-east-1.amazonaws.com/hello-node:latest
docker push <account>.dkr.ecr.us-east-1.amazonaws.com/hello-node:latest

aws ecs update-service --cluster hello-node-cluster --service hello-node-svc --force-new-deployment
```
3. Open the `alb_dns_name` output in a browser.
