## Generated Terraform (minimal)

This Terraform deploys the minimal AWS infrastructure implied by the repository:
- An S3 bucket
- A Python Lambda function (from `../lambda.zip`) that moves objects from `source/` to `destination/`
- S3 bucket notification to trigger the Lambda on `s3:ObjectCreated:*` for keys prefixed with `source/`

### Apply
```bash
cd ai_basis_tf
terraform init
terraform apply
```

### Test
1. Create `source/` and `destination/` prefixes (folders) in the bucket (optional; S3 is prefix-based).
2. Upload a file to `source/`.
3. Verify it appears under `destination/`.
