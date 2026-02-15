# Terraform (generated)

This repository does not contain an application runtime (no web server code, no package manifests). It primarily builds a Docker image that bundles Terraform and a `tf-migrate` binary.

To keep the AWS footprint minimal and broadly compatible (including LocalStack-style environments), this Terraform creates a single private S3 bucket for storing artifacts.

## Usage

```bash
cd ai_basis_tf
terraform init
terraform validate
terraform apply
```
