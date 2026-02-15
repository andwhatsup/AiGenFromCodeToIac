## What this Terraform deploys

Minimal AWS infrastructure to run the repository's Lambda-based data fetcher:

- ECR repository to store the Lambda container image
- IAM role for Lambda + basic CloudWatch Logs permissions
- Lambda function (package_type = Image)
- EventBridge schedule to invoke the Lambda periodically

## How to use

1) Deploy ECR first (optional but common workflow):

```bash
terraform init
terraform apply -target=aws_ecr_repository.app
```

2) Build and push the image (from repo root where Dockerfile exists):

```bash
ECR_URL=$(terraform -chdir=ai_basis_tf output -raw ecr_repository_url)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(echo $ECR_URL | cut -d/ -f1)

docker build -t home-automation .
docker tag home-automation:latest ${ECR_URL}:latest
docker push ${ECR_URL}:latest
```

3) Apply the rest:

```bash
terraform apply
```

Provide secrets via `terraform.tfvars` or environment variables.
