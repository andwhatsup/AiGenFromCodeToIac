output "s3_bucket_name" {
  description = "Name of the created S3 bucket (artifacts/state-like storage)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table suitable for Terraform state locking."
  value       = aws_dynamodb_table.terraform_locks.name
}
