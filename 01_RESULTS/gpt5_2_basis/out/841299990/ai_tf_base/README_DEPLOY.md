# Terraform deployment (ECS Fargate + ALB)

This repo contains a Node.js + Socket.IO chat app (listens on port 12345 by default) with a Dockerfile.

Terraform provisions:
- ECR repository
- ECS cluster + Fargate service
- Application Load Balancer (HTTP :80) forwarding to container port 12345

## Build & push image

After `terraform apply`, push an image to the created ECR repo.

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account_id>.dkr.ecr.us-east-1.amazonaws.com

docker build -t chatapp:latest .
docker tag chatapp:latest <ecr_repository_url>:latest
docker push <ecr_repository_url>:latest
```

Then force a new deployment (optional):
```bash
aws ecs update-service --cluster <ecs_cluster_name> --service chatapp-svc --force-new-deployment
```

Open the app:
- http://<alb_dns_name>/
