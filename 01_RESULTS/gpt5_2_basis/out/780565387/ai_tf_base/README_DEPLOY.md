# Terraform deployment (generated)

This Terraform deploys the `http-echo` Go web server as an **ECS Fargate** service behind an **Application Load Balancer**.

## Build & push container image

Terraform creates an ECR repository. After `terraform apply`, build and push an image tagged `latest`:

```bash
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_URL=$(terraform -chdir=ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker build -t http-echo:latest .
docker tag http-echo:latest ${REPO_URL}:latest
docker push ${REPO_URL}:latest
```

Then browse:

```bash
echo "http://$(terraform -chdir=ai_basis_tf output -raw alb_dns_name)/"
```

The app requires `ECHO_TEXT` (set via Terraform variable `echo_text`).
