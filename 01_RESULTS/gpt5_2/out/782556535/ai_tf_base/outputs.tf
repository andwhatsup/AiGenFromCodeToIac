output "bucket_id" {
  description = "ID (name) of the main S3 bucket."
  value       = aws_s3_bucket.main.id
}

output "logs_bucket_id" {
  description = "ID (name) of the logs S3 bucket."
  value       = aws_s3_bucket.logs.id
}
