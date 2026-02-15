# Generated Terraform (minimal)

This Terraform deploys the app as a container on **ECS Fargate** behind an **Application Load Balancer**.

It uses the **default VPC and its subnets** to stay minimal.

Inputs:
- `container_image` defaults to `yash5090/tribute:latest`
- `container_port` defaults to `3000`

After apply, use output `alb_dns_name`.
