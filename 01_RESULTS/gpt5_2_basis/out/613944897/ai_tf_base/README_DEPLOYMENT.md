# Terraform deployment (minimal)

This Terraform deploys a minimal runtime for the repository's Node.js/Express app using **ECS Fargate + ALB** in the **default VPC**.

## Notes
- The repo contains a Dockerfile, but Terraform does not build/push images.
- By default, this configuration runs a public Node image as a placeholder (`var.image`).
- For a real deployment, build the repo image and push to ECR, then set `-var image=<ecr_image_uri>`.

## Commands
```bash
cd ai_basis_tf
terraform init
terraform validate
terraform apply
```

After apply, open the `alb_dns_name` output in a browser.
