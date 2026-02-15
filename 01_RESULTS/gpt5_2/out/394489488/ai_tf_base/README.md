# Terraform (minimal) - MLflow server

This Terraform stack deploys a minimal MLflow Tracking Server on **AWS App Runner** and an **S3 bucket** for artifacts.

## What it deploys
- S3 bucket for MLflow artifacts
- App Runner service running MLflow (basic auth enabled)
- (Optional) RDS PostgreSQL backend store (disabled by default)

## Usage
```bash
terraform init
terraform apply \
  -var mlflow_username="mlflow" \
  -var mlflow_password="mlflow"
```

Optional RDS backend store:
```bash
terraform apply \
  -var create_backend_store=true \
  -var db_password="change-me" \
  -var mlflow_username="mlflow" \
  -var mlflow_password="mlflow"
```
