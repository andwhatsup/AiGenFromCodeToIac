output "artifact_bucket_name" {
  description = "S3 bucket name for storing build artifacts/static assets"
  value       = aws_s3_bucket.site.bucket
}

output "artifact_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.site.arn
}
