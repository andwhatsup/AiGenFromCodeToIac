## Terraform deployment (minimal)

This repository contains a static HTML/JS game. The minimal AWS infrastructure is an S3 bucket configured for static website hosting.

After `terraform apply`, upload the site files (index.html, script.js, style.css, images/*) to the bucket.

Example:

```bash
aws s3 sync ../ s3://$(terraform output -raw s3_bucket_name) \
  --exclude "ai_basis_tf/*" \
  --exclude ".git/*"
```

Then open the `website_endpoint` output in a browser.
