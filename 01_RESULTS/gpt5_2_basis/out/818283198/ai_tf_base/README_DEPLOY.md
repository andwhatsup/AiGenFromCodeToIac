# Terraform deployment (generated)

This repository contains a Docker-based AWS Lambda function that runs Playwright.

## What this Terraform creates
- ECR repository for the Lambda container image
- IAM role for Lambda execution + basic CloudWatch Logs permissions
- Lambda function using `package_type = "Image"`

## Deploy steps
1. `terraform init && terraform apply` (creates ECR + Lambda)
2. Build and push the image to ECR (see repo `Makefile` target `docker`)
3. Update the Lambda to the pushed image tag if needed

Note: Terraform validation does not require the image to exist, but `terraform apply` will.
