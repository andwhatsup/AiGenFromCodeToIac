# Terraform deployment (minimal)

This Terraform creates a minimal AWS deployment for the repository's URL shortener web app:

- ECR repository (push your image)
- ECS Fargate service
- Application Load Balancer (HTTP/80)

## Build & push image

1. Authenticate to ECR
2. Build and push an image tagged `:latest` to the output `ecr_repository_url`.

## Notes

- The application code in this repo uses SQLite by default; this deployment does not provision an external database.
- For production, consider RDS (PostgreSQL/MySQL) and secrets management.
