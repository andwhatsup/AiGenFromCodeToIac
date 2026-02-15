output "s3_artifacts_bucket_name" {
  description = "S3 bucket for storing datasets/notebook artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}

output "aws_region" {
  description = "AWS region used by the provider."
  value       = var.aws_region
}
