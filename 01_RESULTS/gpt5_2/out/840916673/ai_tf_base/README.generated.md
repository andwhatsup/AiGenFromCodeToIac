# Generated Terraform

This Terraform deploys a minimal AWS footprint inferred from the repository:
- Static web assets (`index.html`, `script2.js`, `style2.css`) are uploaded to an S3 bucket.
- S3 website hosting is enabled.

Note: The bucket is configured with **Block Public Access** enabled (private). For a publicly accessible website, add CloudFront + Origin Access Control (recommended) or relax the bucket policy (not recommended).
