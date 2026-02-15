## Terraform: Minimal AWS infra for Flask calculator

This repository contains a simple Flask web app (port 5000) with a Dockerfile and Kubernetes manifests.

This Terraform deploys the app to **ECS Fargate** behind an **Application Load Balancer (HTTP/80)** using the **default VPC/subnets**.

### Inputs
- `aws_region` (default: us-east-1)
- `app_name` (default: calculator-flask)
- `container_image` (default: yash5090/calculator-flask:latest)
- `desired_count` (default: 2)

### Outputs
- `alb_dns_name`

### Run
```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
```
