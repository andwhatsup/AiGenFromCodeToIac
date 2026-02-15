output "s3_bucket_name" {
  description = "Name of the created S3 bucket (if enabled)."
  value       = try(aws_s3_bucket.artifacts[0].bucket, null)
}

output "dynamodb_table_name" {
  description = "Name of the created DynamoDB table (if enabled)."
  value       = try(aws_dynamodb_table.example[0].name, null)
}
