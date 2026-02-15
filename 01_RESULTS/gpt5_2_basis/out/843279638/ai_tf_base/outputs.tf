output "site_bucket_name" {
  description = "S3 bucket intended to hold the built static site (private by default)."
  value       = aws_s3_bucket.site.bucket
}

output "artifacts_bucket_name" {
  description = "S3 bucket intended to hold build artifacts (private)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "aws_region" {
  value = var.aws_region
}
