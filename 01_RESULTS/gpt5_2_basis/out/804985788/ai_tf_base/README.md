# Terraform (minimal AWS baseline)

This repository is a Rust-based CLI/tooling project (with a Dockerfile that installs `gnucobol`).
There is no long-running web service to expose.

Minimal infrastructure provisioned:
- **S3 bucket** for storing build artifacts (e.g., generated COBOL source files, compiled binaries, logs).

## Usage

```bash
terraform init
terraform validate
terraform apply
```
