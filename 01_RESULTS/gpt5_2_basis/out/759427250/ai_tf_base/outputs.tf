output "s3_bucket_name" {
  description = "Artifact bucket name."
  value       = aws_s3_bucket.artifacts.bucket
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = aws_dynamodb_table.app.name
}
