# Terraform deployment (generated)

This Terraform deploys the repository's Flask app container as an **ECS Fargate** service behind an **Application Load Balancer**.

## Inputs
- `container_image` defaults to `xmaeltht/python-webapp:latest` (from `k8s-deployment.yaml`).

## Run
```bash
cd ai_basis_tf
terraform init
terraform apply
```

After apply, open the `alb_dns_name` output in a browser.
