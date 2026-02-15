output "artifact_bucket_name" {
  description = "S3 bucket for build artifacts / container build context outputs"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}
