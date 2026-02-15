# Terraform (minimal) for nodejs-docker-example

This repository is primarily a CI example (Buildkite + Docker) and does not define a clear long-running web service.
The `docker-compose.yml` references an ECR image, so this Terraform creates an ECR repository (and a log group for future ECS usage).

## Next steps (manual)

1. Build and push your image:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com

docker build -t nodejs-docker-example .
docker tag nodejs-docker-example:latest <ecr_repository_url>:latest
docker push <ecr_repository_url>:latest
```

2. If you later add a web server entrypoint, you can extend this to ECS Fargate + ALB.
