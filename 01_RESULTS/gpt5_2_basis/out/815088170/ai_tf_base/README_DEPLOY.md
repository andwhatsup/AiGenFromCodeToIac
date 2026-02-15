# Terraform deployment (ECS Fargate + ALB)

This repo contains a simple Node/Express app listening on port 3000.

## What this Terraform creates
- ECR repository (push your image here)
- ECS cluster + Fargate service
- Application Load Balancer (HTTP :80) forwarding to the service
- CloudWatch log group

## Build & push image
After `terraform apply`, use the output `ecr_repository_url`.

Example:
```bash
AWS_REGION=us-east-1
REPO_URL=$(terraform -chdir=ai_basis_tf output -raw ecr_repository_url)

docker build -t hello-world:latest -f dockerfile .
docker tag hello-world:latest ${REPO_URL}:latest
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REPO_URL%/*}
docker push ${REPO_URL}:latest
```

Then update the ECS service (it will pick up `:latest` on new deployments) or force a new deployment:
```bash
aws ecs update-service --cluster hello-world-cluster --service hello-world-service --force-new-deployment
```

## Access
Use the output `alb_dns_name`:
```bash
curl http://$(terraform -chdir=ai_basis_tf output -raw alb_dns_name)/
```
