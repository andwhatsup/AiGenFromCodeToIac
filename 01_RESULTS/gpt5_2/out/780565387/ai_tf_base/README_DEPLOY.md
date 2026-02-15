# Terraform deployment (ECS Fargate)

This Terraform creates minimal AWS infrastructure to run the `http-echo` container on ECS Fargate behind an ALB.

## Build & push image

1. Authenticate to ECR
2. Build and push `:latest` to the repository output `ecr_repository_url`.

Example:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com

docker build -t http-echo:latest .
docker tag http-echo:latest <ecr_repository_url>:latest
docker push <ecr_repository_url>:latest
```

Then apply Terraform and open the `alb_dns_name` output.

The app requires `ECHO_TEXT` (set via Terraform variable `echo_text`).
