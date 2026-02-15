# Terraform deployment (generated)

This repository contains a React app. The simplest AWS runtime is static hosting:

- Build the app locally/CI: `npm ci && npm run build`
- Upload `build/` to the S3 bucket output by Terraform
- Access via the CloudFront domain output by Terraform

Example upload:

```bash
aws s3 sync build/ s3://$(terraform output -raw s3_bucket_name)/ --delete
```
