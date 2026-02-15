# Terraform baseline for epicac

This repository is primarily a demo utility for **Amazon EKS Pod Identity cross-account credentials**.
The runtime target is Kubernetes (EKS), but standing up a full EKS cluster is not minimal.

This Terraform creates the minimal AWS-side infrastructure you need to build/push the container image:
- An **ECR repository** for the image
- An **S3 bucket** for optional artifacts

## Build & push

1. `terraform output -raw ecr_repository_url`
2. Authenticate and push (example):

```bash
AWS_REGION=us-east-1
REPO=$(terraform output -raw ecr_repository_url)
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REPO

docker build -t $REPO:latest .
docker push $REPO:latest
```

## Run on EKS

Use your existing EKS cluster and apply `pod.yaml` after updating:
- `image:` to the pushed ECR image
- `role_arn` in `aws-config`

EKS Pod Identity association and cross-account IAM roles are environment-specific and intentionally not created here.
