## Terraform deployment (minimal)

This repository contains boto3 workshop scripts that interact with S3 (upload/download/list).
The minimal infrastructure to support the scripts is an S3 bucket with private access.

### Deploy
```bash
cd workspace/648880895/ai_basis_tf
terraform init
terraform apply
```

### Use with scripts
Update the bucket name in the Python scripts (e.g. `s3-bucket-workshop-1001-pyday`) to the Terraform output `bucket_name`.

### Destroy
```bash
terraform destroy
```
