# Terraform baseline (generated)

This repository contains a simple Flask app (Dockerfile provided) and references ActiveMQ.

To keep the infrastructure minimal and broadly applicable, this Terraform creates:
- An S3 bucket for artifacts
- A minimal IAM role stub suitable for a future ECS task role

You can extend this to ECS Fargate + ALB and an ActiveMQ broker (e.g., Amazon MQ) if/when needed.
