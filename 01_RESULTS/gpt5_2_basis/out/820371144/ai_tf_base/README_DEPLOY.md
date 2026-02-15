# Terraform (minimal) deployment

This Terraform deploys the React app container as an **ECS Fargate** service behind an **Application Load Balancer**, using the **default VPC**.

## Build & push image
1. `terraform output -raw ecr_repository_url`
2. Authenticate Docker to ECR:
   - `aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account>.dkr.ecr.<region>.amazonaws.com`
3. Build and push:
   - `docker build -t app .`
   - `docker tag app:latest <ecr_repository_url>:latest`
   - `docker push <ecr_repository_url>:latest`

Then (re)deploy:
- `terraform apply`

Open:
- `terraform output -raw alb_dns_name`
