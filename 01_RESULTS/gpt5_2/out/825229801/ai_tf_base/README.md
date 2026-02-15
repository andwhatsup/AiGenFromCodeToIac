## Terraform: Minimal AWS infrastructure for this repository

Repository contents indicate a static web game (index.html, script.js, style.css) and an optional container image (nginx) used to serve it.

This Terraform creates a minimal S3 bucket suitable for storing/hosting the static site artifacts.

### Commands

```bash
terraform init
terraform validate
terraform plan
```
