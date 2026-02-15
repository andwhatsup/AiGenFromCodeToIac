# Generated Terraform (minimal)

This Terraform deploys the Strapi app as a container on **ECS Fargate** behind an **Application Load Balancer** in the **default VPC**.

## What you must provide
- `container_image`: a public image (default is Docker Hub `camillehe1992/strapi:latest`) or an ECR image URI.
- `app_env`: Strapi environment variables (secrets, DB config). Defaults are placeholders and use sqlite for minimal infra.

## Run
```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
```

After apply, open:
- `http://<alb_dns_name>`
