# Terraform deployment (minimal)

This repo contains a simple FastAPI app (see `tla_example/src/main.py`) and a `Dockerfile`.
The Terraform in this folder deploys a minimal ECS Fargate service in the **default VPC** with a public IP.

## Build & push image

1. Authenticate to ECR
2. Build and push the image tagged `latest` to the output `ecr_repository_url`.

Example (adjust region/account):

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account>.dkr.ecr.us-east-1.amazonaws.com

docker build -t tla-example:latest ..
docker tag tla-example:latest <ecr_repository_url>:latest
docker push <ecr_repository_url>:latest
```

## Apply

```bash
terraform init
terraform apply
```

Note: This minimal setup does not include an ALB; the task gets a public IP and the security group allows inbound traffic to port 8080.
