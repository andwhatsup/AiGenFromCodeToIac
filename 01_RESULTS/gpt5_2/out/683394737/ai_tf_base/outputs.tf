output "aws_region" {
  description = "Region in which resources were created"
  value       = var.aws_region
}

output "artifact_bucket_name" {
  description = "S3 bucket for artifacts/static assets"
  value       = aws_s3_bucket.artifacts.bucket
}
