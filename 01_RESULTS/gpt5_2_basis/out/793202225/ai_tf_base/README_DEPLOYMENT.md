# Terraform (minimal) deployment

This repository contains a Rust Axum web server listening on `0.0.0.0:3000`.

This Terraform creates a minimal ECS Fargate service in the **default VPC** and exposes the container port directly via a security group (public IP).

## Notes
- `container_image` defaults to a public nginx image so `terraform validate` works without requiring an ECR build/push.
- To run the actual app, build and push your image to ECR and set `-var container_image=<your_ecr_image_uri>`.
- For production, you would typically add an ALB and restrict inbound traffic.
