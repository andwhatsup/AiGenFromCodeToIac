# Terraform baseline (ai_basis_tf)

This repository contains a React (create-react-app) application. The simplest AWS deployment target is static hosting.

This Terraform creates a private S3 bucket suitable for storing the `npm run build` output.

## Typical usage

1. Build the app locally:

```bash
npm ci
npm run build
```

2. Upload build artifacts to the bucket (example):

```bash
aws s3 sync build/ s3://$(terraform output -raw s3_bucket_name)/
```

To serve publicly, you would typically add CloudFront + an origin access control (OAC) and a bucket policy, or enable S3 website hosting (not recommended for production).
