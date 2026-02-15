## Terraform deployment

This repository contains a simple Flask app (Gunicorn on port 8080) and a Waypoint config that can deploy to ECS.

This Terraform creates a minimal AWS ECS Fargate service behind an Application Load Balancer in the **default VPC**.

### Required input

- `image` (string): container image URI to run (e.g. `public.ecr.aws/nginx/nginx:latest` or your pushed image).

### Example

```bash
cd ai_basis_tf
terraform init
terraform apply -var='image=YOUR_IMAGE_URI'
```

After apply, open the `alb_dns_name` output in a browser.
