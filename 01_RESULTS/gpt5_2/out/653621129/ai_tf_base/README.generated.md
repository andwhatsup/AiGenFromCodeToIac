# Generated Terraform (minimal)

This Terraform deploys the repository's containerized `hello-world-server` as an **ECS Fargate** service behind an **Application Load Balancer**.

It uses the **default VPC and its subnets** to keep the stack minimal.

## Inputs
- `image_name` (default: `robbiearms/hello-world:latest`)
- `aws_region` (default: `us-east-1`)

## Outputs
- `endpoint` - URL to access the service
