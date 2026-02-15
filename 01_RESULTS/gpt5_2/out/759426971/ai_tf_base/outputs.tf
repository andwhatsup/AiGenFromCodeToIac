output "s3_bucket_name" {
  description = "Artifacts bucket name."
  value       = aws_s3_bucket.artifacts.bucket
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = aws_dynamodb_table.app.name
}

output "localstack_endpoint" {
  description = "LocalStack endpoint used by the provider."
  value       = var.localstack_endpoint
}
