output "artifacts_bucket_name" {
  description = "S3 bucket for storing build artifacts or runtime assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "aws_region" {
  value = var.aws_region
}
