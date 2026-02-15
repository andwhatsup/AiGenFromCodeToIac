# Terraform - VAT Calculator (minimal AWS infra)

This repository contains a static HTML/CSS/JS VAT calculator.

## What this Terraform creates
- An S3 bucket (private by default) suitable for storing/hosting the static site artifacts.

> Note: This is intentionally minimal and conservative to validate/apply in many environments.
> If you want public static website hosting, add CloudFront + an origin access control (OAC)
> and a bucket policy, or enable S3 website hosting with public access (not recommended).

## Usage
```bash
terraform init
terraform validate
terraform apply
```
