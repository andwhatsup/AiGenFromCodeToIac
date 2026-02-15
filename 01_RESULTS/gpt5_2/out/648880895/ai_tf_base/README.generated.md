# Generated Terraform (minimal)

This repository contains boto3 workshop scripts that interact with AWS S3 (and optionally EC2 listing).
The minimal infrastructure to support the workshop is an S3 bucket with public access blocked.

## What this creates
- One S3 bucket (unique name with random suffix)
- Public access block (all enabled)
- Versioning enabled
- SSE-S3 (AES256) enabled
- A small placeholder object at `images/lp1.jpeg`

## Usage
```bash
cd ai_basis_tf
terraform init
terraform apply
```
Then use the output `s3_bucket_name` in the Python scripts.
