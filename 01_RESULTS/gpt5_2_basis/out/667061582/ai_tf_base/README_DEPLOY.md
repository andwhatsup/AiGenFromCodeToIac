# Deploy notes (out of band)

This Terraform creates minimal AWS infrastructure to run the repository's Tomcat-based WAR as a container on **ECS Fargate** behind an **Application Load Balancer**.

## Build & push image

1. Build the WAR and container image locally:

```bash
mvn -q -DskipTests package

docker build -t app:latest .
```

2. Authenticate to ECR and push:

```bash
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account_id>.dkr.ecr.<region>.amazonaws.com

docker tag app:latest $(terraform output -raw ecr_repository_url):latest

docker push $(terraform output -raw ecr_repository_url):latest
```

3. Force a new deployment:

```bash
aws ecs update-service --cluster $(terraform output -raw ecs_cluster_name) --service $(terraform output -raw ecs_service_name) --force-new-deployment
```

Then open the ALB URL:

```bash
echo "http://$(terraform output -raw alb_dns_name)/"
```
