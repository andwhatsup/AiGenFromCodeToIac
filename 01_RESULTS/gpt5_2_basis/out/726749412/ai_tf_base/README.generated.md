# Generated Terraform (baseline)

## What was detected in the repository
- Node.js/Express app (`server.js`) serving `index.html` and `about.html` on port 3000
- `Dockerfile` builds a container and exposes port 3000
- CI pipeline (Jenkinsfile) builds and pushes a Docker image to DockerHub

## Minimal infrastructure chosen
To keep the deployment minimal and broadly compatible (including LocalStack-style environments), this Terraform creates:
- An S3 bucket for application/CI artifacts (versioned, encrypted, and blocked from public access)

## Next step (optional)
If you want to run the container on AWS, extend this baseline with:
- ECR repository
- ECS cluster + Fargate service
- ALB + target group + listener
- IAM task execution role

This is intentionally not included to keep the generated configuration small and easy to validate.
