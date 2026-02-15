# Terraform baseline for DevSecOps-Batry-Indicator-Deployment

## What this repo contains
The application is a static HTML/CSS/JS site packaged into an Nginx container (see `Dockerfile`).
There are also Kubernetes manifests (`deployment.yaml`, `service.yaml`) that would typically be used on a cluster.

## Minimal AWS infrastructure generated
To keep the deployment target minimal and broadly compatible (including LocalStack-style environments), this Terraform creates:
- An S3 bucket suitable for storing the static site artifacts (or container build artifacts).

This is intentionally a baseline; you can extend it to:
- S3 static website hosting + CloudFront
- ECS Fargate + ALB (to run the Nginx container)
- EKS (to run the provided Kubernetes manifests)
