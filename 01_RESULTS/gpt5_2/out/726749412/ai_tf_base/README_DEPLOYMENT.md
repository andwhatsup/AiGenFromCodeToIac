# Terraform (minimal) for this repository

This repo contains a simple Node.js/Express app (listens on port 3000) and a Dockerfile.

To keep the infrastructure minimal and broadly compatible (including LocalStack-style environments), this Terraform creates:
- An S3 bucket for artifacts/static assets
- A minimal IAM role stub for a future runtime (e.g., ECS task role)

You can extend this to ECS Fargate + ALB + ECR if you want a full container deployment.
