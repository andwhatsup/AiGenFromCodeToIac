# Generated Terraform (AWS)

This Terraform deploys the repository's Tomcat-based webapp container as an **ECS Fargate** service behind an **Application Load Balancer**.

## Inputs
- `container_image` defaults to `balcha/stackfusion` (as referenced in the repo's Kubernetes manifest). Override to your own ECR image if desired.
- `container_port` defaults to `8080` (matches the Dockerfile's Tomcat port).

## Run
```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
```
