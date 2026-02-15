## Terraform (minimal) for DevSecOps Python Flask Calculator

This repository contains a simple Flask web app (calculator) and Kubernetes manifests.
This Terraform deploys the app as a container on **ECS Fargate** behind an **Application Load Balancer** using the **default VPC**.

### What it creates
- ECS Cluster, Task Definition, Service (Fargate)
- ALB + Listener + Target Group
- Security groups
- CloudWatch Log Group
- IAM task execution role

### Inputs
- `container_image` defaults to `yash5090/py-calc-app:latest` (from `deployment.yaml`)
- `container_port` defaults to `5000` (from `deployment.yaml`/`service.yaml`)

### Outputs
- `alb_dns_name`
