# Terraform (AWS) - Minimal baseline

This repository is primarily a data/notebook challenge that uses Aiven-managed services (ClickHouse, Kafka, etc.).
There is no clear AWS runtime (no Dockerfile, no web server, no Lambda).

This Terraform creates a minimal, safe AWS baseline resource:
- An S3 bucket for storing artifacts (datasets, notebook exports, query results).

## Usage

```bash
terraform init
terraform validate
terraform plan
terraform apply
```
