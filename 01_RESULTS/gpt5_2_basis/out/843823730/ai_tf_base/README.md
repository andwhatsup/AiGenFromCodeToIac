## Terraform (minimal) for Notes Keeper static site

This repository contains a simple static HTML/CSS/JS notes app. The minimal AWS infrastructure to host it is an S3 bucket configured for static website hosting.

### What this Terraform creates
- S3 bucket (unique name)
- S3 static website configuration (index.html)
- Bucket policy allowing public read of objects (for website hosting)

### Deploy
```bash
cd ai_basis_tf
terraform init
terraform apply
```

### Upload site files
Terraform does not upload the website assets. Upload `index.html`, `style.css`, `script.js` etc.:
```bash
aws s3 sync .. s3://$(terraform output -raw s3_bucket_name) --exclude "ai_basis_tf/*"
```
Then open the `website_endpoint` output.
