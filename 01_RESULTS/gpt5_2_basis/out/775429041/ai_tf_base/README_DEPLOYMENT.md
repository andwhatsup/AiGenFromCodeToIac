## Terraform deployment (minimal)

This repo is a React app with a Dockerfile and Kubernetes manifests exposing port 3000.
The Terraform in this folder deploys the container image to **ECS Fargate** in the **default VPC**, with a public IP.

### What it creates
- ECS Cluster
- ECS Task Definition + Service (Fargate)
- CloudWatch Log Group
- IAM task execution role (AmazonECSTaskExecutionRolePolicy)
- Security group allowing inbound traffic to `container_port` (default 3000)

### Notes
- This is a minimal baseline and does not include an ALB. You can reach the task via its public IP (discoverable in ECS console).
- The container image defaults to `yash5090/react-jg-app:latest` as referenced in `deployment.yaml`.
