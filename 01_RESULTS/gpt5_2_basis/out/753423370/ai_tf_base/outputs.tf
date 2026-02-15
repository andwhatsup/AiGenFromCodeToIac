output "s3_bucket_name" {
  description = "S3 bucket to upload the built frontend (e.g., React build/ directory) artifacts."
  value       = aws_s3_bucket.frontend_artifacts.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the artifacts bucket."
  value       = aws_s3_bucket.frontend_artifacts.arn
}
