# Terraform deployment (generated)

This repo contains a Lambda function packaged as a **container image** (see `Dockerfile`).

Terraform creates:
- ECR repository
- IAM role + policies for Lambda
- Lambda function (image-based)
- EventBridge schedule trigger
- S3 bucket + CloudTrail (optional but included as baseline audit trail)

## Build & push image

Terraform references the image as:

`<account>.dkr.ecr.<region>.amazonaws.com/<ecr_repo_name>:<image_tag>`

Build and push (example):

```bash
export AWS_REGION=us-east-1
export ECR_REPO_NAME=aws-iam-gitops
export IMAGE_TAG=latest

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO_URI=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

docker build --platform linux/amd64 \
  --build-arg GITHUB_USERNAME=<user> \
  --build-arg GITHUB_REPO=<repo> \
  --build-arg GITHUB_TOKEN=<token> \
  -t ${REPO_URI}:${IMAGE_TAG} .

docker push ${REPO_URI}:${IMAGE_TAG}
```

## Terraform

```bash
terraform init
terraform apply \
  -var github_username=<user> \
  -var github_repo=<repo> \
  -var github_token=<token> \
  -var image_tag=latest
```
