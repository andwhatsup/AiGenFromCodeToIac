# Terraform deployment (minimal)

This repository contains a simple static website (`index.html`, `app.js`, `style.css`).

The Terraform in this folder provisions:
- An S3 bucket
- S3 static website hosting configuration
- A public-read bucket policy (so the website is reachable)

## Deploy

```bash
terraform init
terraform apply
```

## Upload site content

Terraform does not upload the website files. After `apply`, upload the files:

```bash
aws s3 sync .. s3://$(terraform output -raw s3_bucket_name) --delete
```

Then open the `website_endpoint` output in a browser.
