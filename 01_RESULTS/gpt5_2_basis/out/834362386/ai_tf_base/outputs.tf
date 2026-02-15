output "site_bucket_name" {
  description = "S3 bucket name for hosting static site assets (private by default)."
  value       = aws_s3_bucket.site.bucket
}

output "artifacts_bucket_name" {
  description = "S3 bucket name for build/deployment artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}
