output "s3_artifacts_bucket_name" {
  description = "S3 bucket name for artifacts/static files."
  value       = aws_s3_bucket.artifacts.bucket
}

output "s3_artifacts_bucket_arn" {
  description = "S3 bucket ARN for artifacts/static files."
  value       = aws_s3_bucket.artifacts.arn
}
