# Terraform (minimal AWS baseline)

This repository is primarily a homelab configuration (Nomad/Consul + Nomad jobs).
There is no AWS runtime application to deploy.

This Terraform creates a minimal, safe AWS baseline resource:
- An S3 bucket for storing artifacts/configs/backups.

## Usage

```bash
terraform init
terraform validate
terraform apply
```
