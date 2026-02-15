# Terraform deployment (generated)

This Terraform deploys a minimal AWS target inferred from the repository: an S3 bucket configured for static website hosting.

## Commands

```bash
cd workspace/846925874/ai_basis_tf
terraform init
terraform apply
```

After apply, use the `website_endpoint` output.

## Upload site content

This Terraform intentionally does not upload local files to S3 (to keep it minimal and deterministic). Upload your static files:

```bash
aws s3 sync /path/to/repo s3://$(terraform output -raw s3_bucket_name) \
  --exclude "*.tf" --exclude ".git/*" --exclude "EKS-Terraform/*" --exclude "ai_basis_tf/*"
```
