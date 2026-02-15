output "artifact_bucket_name" {
  description = "S3 bucket for storing build artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the artifact bucket."
  value       = aws_s3_bucket.artifacts.arn
}
