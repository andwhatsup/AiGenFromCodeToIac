# Terraform baseline for VAT Calculator

This repository contains a static HTML/CSS/JS app (see `index.html`, `style.css`, `script.js`).
A `Dockerfile` exists that serves the static content via Nginx.

To keep the infrastructure minimal and broadly compatible (including LocalStack-style environments),
this Terraform creates:
- A private S3 bucket for site assets
- A private S3 bucket for artifacts

You can upload the static files to the `site_bucket_name` bucket using `aws s3 sync`.

If you want public hosting, add CloudFront + an Origin Access Control (or S3 website hosting + public policy).
