output "artifacts_bucket_name" {
  description = "S3 bucket for storing artifacts/outputs."
  value       = aws_s3_bucket.artifacts.bucket
}
