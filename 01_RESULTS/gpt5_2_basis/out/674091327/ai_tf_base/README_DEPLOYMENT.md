# Terraform (minimal AWS baseline)

This repository contains a simple Flask app (Dockerized) and example Kubernetes manifests for ActiveMQ.

To keep the AWS infrastructure minimal and broadly compatible (including LocalStack-style environments),
this Terraform creates an S3 bucket for artifacts.

## Commands

```bash
cd ai_basis_tf
terraform init
terraform validate
terraform plan
terraform apply
```
