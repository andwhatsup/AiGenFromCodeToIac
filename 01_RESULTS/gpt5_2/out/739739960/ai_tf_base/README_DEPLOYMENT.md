# Terraform deployment (minimal)

This Terraform creates an S3 bucket configured for **static website hosting** and a public-read bucket policy.

## Build the site

From repo root:

```bash
npm ci
npm run build
```

Parcel will output to `dist/` by default.

## Upload

After `terraform apply`, upload your built assets:

```bash
aws s3 sync dist/ s3://$(terraform -chdir=workspace/739739960/ai_basis_tf output -raw s3_bucket_name)/
```

Then open the `s3_website_endpoint` output.
