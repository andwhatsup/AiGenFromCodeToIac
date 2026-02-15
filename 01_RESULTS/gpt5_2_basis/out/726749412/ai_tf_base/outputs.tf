output "artifact_bucket_name" {
  description = "S3 bucket for CI/build artifacts related to the application."
  value       = aws_s3_bucket.artifacts.bucket
}

output "aws_region" {
  description = "AWS region used by the provider."
  value       = var.aws_region
}
