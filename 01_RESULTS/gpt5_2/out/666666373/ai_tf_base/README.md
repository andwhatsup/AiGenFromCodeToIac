# Terraform: minimal AWS infra for mvn-hello-world

This repository contains a simple Java WAR deployed to Tomcat (see `Dockerfile`).

This Terraform creates a minimal runtime on AWS using **ECS Fargate** with a public IP.
It does **not** build/push the image; provide an image via `var.container_image` (e.g., an ECR image URI),
or it will run the public `tomcat:8.0` image.

## Usage

```bash
terraform init
terraform validate
terraform plan \
  -var aws_region=us-east-1 \
  -var container_image=123456789012.dkr.ecr.us-east-1.amazonaws.com/mvn-hello-world:latest
```
