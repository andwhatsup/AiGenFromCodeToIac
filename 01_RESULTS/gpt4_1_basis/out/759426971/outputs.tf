output "artifact_bucket_name" {
  value = aws_s3_bucket.artifact.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.state.name
}
