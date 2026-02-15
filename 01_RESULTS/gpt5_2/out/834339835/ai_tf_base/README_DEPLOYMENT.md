## Terraform deployment (minimal)

This repository is a static HTML/CSS/JS loan calculator. The minimal AWS infrastructure to run it is an S3 bucket configured for static website hosting.

This Terraform creates:
- S3 bucket (random suffix)
- S3 website configuration (index.html)
- Public read bucket policy (for website hosting)

After apply, upload `index.html` and `style.css` to the bucket.

Example:
```bash
aws s3 cp index.html s3://$(terraform output -raw s3_bucket_name)/index.html --content-type text/html
aws s3 cp style.css s3://$(terraform output -raw s3_bucket_name)/style.css --content-type text/css
```

Then open the `s3_website_endpoint` output in a browser.
