# Terraform deployment (minimal)

This Terraform deploys the repo's `serve.py` container as an **ECS Fargate** service in the **default VPC**, and creates an **ECR** repository to push the image.

## Build & push image

```bash
AWS_REGION=eu-central-1
APP_NAME=echo-server
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URL=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker build -t ${ECR_URL}:latest ..
docker push ${ECR_URL}:latest
```

## Deploy

```bash
cd ai_basis_tf
terraform init
terraform apply -auto-approve
```

Note: This minimal setup exposes the task directly via a public IP and security group on port 8080 (no ALB). For production, add an ALB.
