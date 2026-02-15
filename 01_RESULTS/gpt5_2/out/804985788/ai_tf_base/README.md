# Terraform (minimal) for rust-cobol-generator

This repository is a Rust macro example that generates COBOL source code. It does not require always-on AWS compute to run.

This Terraform creates a minimal AWS footprint:
- An S3 bucket to store generated COBOL artifacts/build outputs.

## Usage

```bash
terraform init
terraform validate
terraform apply
```
