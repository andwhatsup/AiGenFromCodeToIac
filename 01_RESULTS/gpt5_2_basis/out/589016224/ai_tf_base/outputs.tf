output "artifacts_bucket_name" {
  description = "S3 bucket for storing artifacts/configs/backups."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket."
  value       = aws_s3_bucket.artifacts.arn
}
