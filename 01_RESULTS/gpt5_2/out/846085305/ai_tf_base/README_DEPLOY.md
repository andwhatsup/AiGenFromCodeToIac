# Terraform deployment (minimal)

This Terraform deploys:
- An ECR repository to store the Lambda container image
- A Lambda function (container image)
- An EventBridge schedule to invoke the Lambda periodically

## Build & push image

From repo root:

```bash
APP=home-automation
cd .. # repo root

# Build
docker build -t ${APP}:latest .

# Get ECR URL
cd ai_basis_tf
terraform init
terraform apply -target=aws_ecr_repository.app
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login and push
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${ECR_URL%/*}
docker tag ${APP}:latest ${ECR_URL}:latest
docker push ${ECR_URL}:latest

# Deploy the Lambda + schedule
terraform apply
```

## Required variables

Provide via `terraform.tfvars`:

```hcl
influxdb_url    = "https://example.com:8086"
influxdb_token  = "..."
influxdb_org    = "..."
influxdb_bucket = "..."
tuya_apikey     = "..."
tuya_apisecret  = "..."
tuya_apisregion = "us"
```
