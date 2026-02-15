# Terraform deployment (minimal)

This Terraform deploys the repository's Flask app as a **single ECS Fargate service** in the **default VPC**, with a security group allowing inbound traffic to the container port.

## Notes
- This is intentionally minimal: it does **not** create an ALB. The task gets a public IP (default) and is reachable directly on the container port.
- Provide a real image URI via `-var container_image=...` (ECR or public registry).

## Commands
```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
terraform apply
```
