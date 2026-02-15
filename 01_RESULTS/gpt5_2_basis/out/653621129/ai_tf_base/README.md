# Terraform (minimal) - hello-world-server

This Terraform stack deploys the repository's containerized `hello-world-server` as an **ECS Fargate** service behind an **Application Load Balancer (HTTP/80)**.

## What it creates
- Uses the **default VPC** and its subnets (no custom VPC)
- ALB + listener (HTTP)
- ECS cluster, task definition, service (Fargate)
- CloudWatch log group
- IAM task execution role (managed policy)

## Inputs
- `container_image` (default: `robbiearms/hello-world:latest`)
- `aws_region`, `app_name`, `desired_count`

## Outputs
- `endpoint` (URL)
