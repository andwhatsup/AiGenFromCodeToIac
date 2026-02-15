# Terraform deployment (minimal)

This repository contains a simple Java WAR deployed on Tomcat (see `Dockerfile`).

This Terraform creates a minimal ECS Fargate service in the **default VPC** and exposes the container port directly via a security group.

## Notes
- The default `image` is `tomcat:9.0.0.M10-jre8-alpine` (placeholder). For a real deployment, build and push your image to ECR and set `-var image=...`.
- No ALB is created to keep the infrastructure minimal.

## Commands
```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
```
