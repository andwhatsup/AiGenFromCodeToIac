output "artifacts_bucket_name" {
  description = "S3 bucket for application artifacts/static exports."
  value       = aws_s3_bucket.artifacts.bucket
}

output "dynamodb_table_name" {
  description = "DynamoDB table name (optional app state/locks)."
  value       = aws_dynamodb_table.app.name
}
