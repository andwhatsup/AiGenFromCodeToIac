# Terraform deployment (AWS)

This Terraform creates a minimal AWS deployment for the Flask app using:
- ECR (container registry)
- ECS Fargate (runs the container)
- ALB (public HTTP endpoint)

## Build & push image

After `terraform apply`, push your image to the created ECR repo:

```bash
AWS_REGION=us-east-1
REPO_URL=$(terraform -chdir=./ai_basis_tf output -raw ecr_repository_url)

aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "${REPO_URL%/*}"

docker build -t "$REPO_URL:latest" .
docker push "$REPO_URL:latest"
```

Then open the ALB URL:

```bash
terraform -chdir=./ai_basis_tf output -raw alb_dns_name
```

## Notes
- Uses the default VPC/subnets in the selected region.
- The ECS task definition references `:latest`; updating the image requires a new task deployment (e.g., `terraform apply` after forcing new deployment or updating task definition).
