output "artifact_bucket_name" {
  description = "S3 bucket for build artifacts / static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}
