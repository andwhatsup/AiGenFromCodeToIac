# Terraform (minimal) for BoxJump Game

This repository contains a static HTML/JS/CSS game. The minimal AWS infrastructure to run it is an S3 bucket configured for static website hosting.

## What this Terraform creates
- S3 bucket
- S3 website configuration (index.html)
- Bucket policy allowing public read of objects (for website hosting)

## Deploy
```bash
cd ai_basis_tf
terraform init
terraform apply
```

Upload your site files (example):
```bash
aws s3 sync .. s3://$(terraform output -raw s3_bucket_name)
```
Then open:
```bash
terraform output -raw website_url
```
