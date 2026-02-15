## Deploy

This Terraform creates a minimal ECS Fargate service behind an ALB.

1) Build and push image to the created ECR repo:

```bash
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.eu-central-1.amazonaws.com

# after terraform apply, use output ecr_repository_url
docker build -t <ecr_repository_url>:latest -f ../Dockerfile ..
docker push <ecr_repository_url>:latest
```

2) Update the service to pull the new image (force new deployment):

```bash
aws ecs update-service --cluster echo-server --service echo-server --force-new-deployment
```

Or set `-var image=<ecr_repository_url>:<tag>` and re-apply.
