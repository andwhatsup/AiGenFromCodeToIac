# Terraform: magic-color (minimal)

This Terraform deploys a minimal static-site hosting setup inferred from the repository contents:
- Static HTML/CSS/JS assets (no backend)
- S3 bucket for storage
- CloudFront distribution in front of the bucket using Origin Access Control (OAC)

## Deploy

```bash
terraform init
terraform apply
```

## Notes
- This does **not** upload site files. You can upload `index.html`, `style2.css`, `script2.js` to the created bucket.
- CloudFront uses the default certificate (no custom domain).
