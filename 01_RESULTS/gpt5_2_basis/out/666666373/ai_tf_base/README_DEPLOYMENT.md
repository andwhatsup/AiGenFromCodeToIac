# Terraform deployment (generated)

This repository contains a Maven WAR app packaged into a Tomcat Docker image (see `Dockerfile`).

This Terraform deploys a minimal AWS runtime:
- ECS Fargate service running the container image
- Application Load Balancer (HTTP :80) forwarding to the service
- CloudWatch Logs log group
- Uses the **default VPC** and its subnets

## Inputs
- `container_image` defaults to `balcha/banking_domin:latest` (as referenced in the Jenkinsfile/K8s manifests).
- `container_port` defaults to `8080` (Dockerfile exposes 8080).

## Apply
```bash
cd ai_basis_tf
terraform init
terraform apply
```

Then open the `alb_dns_name` output in a browser.
