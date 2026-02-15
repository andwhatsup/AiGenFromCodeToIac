# Terraform (generated)

This Terraform deploys the minimal AWS infrastructure inferred from the repository:

- **S3 static website bucket** for the MkDocs site (public read, website hosting)
- **S3 artifacts bucket** for CI/CD uploads (private)

## Usage

```bash
terraform init
terraform apply \
  -var aws_region=us-east-1 \
  -var environment=dev
```

After apply, upload your built MkDocs `site/` directory to the `site_bucket_name`.

Example:

```bash
mkdocs build
aws s3 sync site/ s3://$(terraform output -raw site_bucket_name)/
```
