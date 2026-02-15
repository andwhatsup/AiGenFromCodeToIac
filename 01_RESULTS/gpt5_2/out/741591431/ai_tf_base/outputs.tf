output "s3_bucket_name" {
  description = "S3 bucket for React build artifacts/static hosting."
  value       = aws_s3_bucket.app.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.app.arn
}
