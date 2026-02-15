# Terraform (minimal) for Battery Indicator app

## What was inferred from the repo
- The repository contains `index.html`, `style.css`, and `script.js` and a `Dockerfile` that serves them via **nginx**.
- Kubernetes manifests exist, but for a minimal AWS deployment target, this Terraform creates an **S3 bucket configured for static website hosting**.

This is intentionally minimal and should `terraform init` + `terraform validate` cleanly.

## Notes
- The bucket is **not public** by default (public access is blocked). To actually serve a public website you would typically add CloudFront + an Origin Access Control (OAC) and a bucket policy.
- Bucket names are globally unique; the configuration uses `account_id` + region to reduce collisions.
