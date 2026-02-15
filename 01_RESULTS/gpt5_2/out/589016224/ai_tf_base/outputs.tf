output "artifacts_bucket_name" {
  description = "S3 bucket for storing artifacts/configs related to the homelab setup."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}
