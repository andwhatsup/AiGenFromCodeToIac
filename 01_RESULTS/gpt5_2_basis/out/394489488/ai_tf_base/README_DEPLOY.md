# Terraform (minimal) for mlflow-server

This Terraform creates:
- S3 bucket for MLflow artifacts
- ECR repository for the container image
- Aurora Serverless v2 (PostgreSQL) backend store
- App Runner service (expects an image pushed to ECR)

## Build & push image

```bash
AWS_REGION=us-east-1
REPO_URL=$(terraform -chdir=ai_basis_tf output -raw ecr_repository_url)
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${REPO_URL%/*}

docker build -t mlflow-server:latest .
docker tag mlflow-server:latest ${REPO_URL}:latest
docker push ${REPO_URL}:latest
```

## Apply

```bash
terraform -chdir=ai_basis_tf apply \
  -var mlflow_username="mlflow" \
  -var mlflow_password="mlflow"
```
