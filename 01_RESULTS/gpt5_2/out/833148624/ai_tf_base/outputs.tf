output "artifacts_bucket_name" {
  description = "S3 bucket for storing artifacts/configs for the DevOps lab."
  value       = aws_s3_bucket.artifacts.bucket
}

output "aws_region" {
  value = var.aws_region
}
