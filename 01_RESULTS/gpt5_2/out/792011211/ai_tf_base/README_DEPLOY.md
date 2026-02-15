# Terraform (minimal) - Python Weather App

This Terraform deploys the app as a container on **ECS Fargate** behind an **Application Load Balancer**, using:
- Default VPC + default subnets
- ECR repository (you build/push the image)
- Secrets Manager secret injected into the container as env var `API_KEY`

## Prereqs
1. Create the secret (must exist before `terraform apply`):

```bash
aws secretsmanager create-secret \
  --name /python-weather-app/api-key \
  --region us-east-1 \
  --secret-string '{"API_KEY":"YOUR_KEY"}'
```

2. Build and push the Docker image after `terraform apply` creates ECR:

```bash
AWS_REGION=us-east-1
REPO_URL=$(terraform -chdir=workspace/792011211/ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(echo $REPO_URL | cut -d/ -f1)

docker build -t python-weather-app .
docker tag python-weather-app:latest ${REPO_URL}:latest
docker push ${REPO_URL}:latest
```

3. Redeploy service (force new deployment):

```bash
aws ecs update-service \
  --cluster python-weather-app-cluster \
  --service python-weather-app-svc \
  --force-new-deployment \
  --region us-east-1
```

Then open the ALB DNS name from Terraform output `alb_dns_name`.
