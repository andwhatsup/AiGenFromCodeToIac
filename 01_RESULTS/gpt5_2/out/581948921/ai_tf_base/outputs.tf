output "site_bucket_name" {
  description = "S3 bucket name hosting the MkDocs static site."
  value       = aws_s3_bucket.site.bucket
}

output "site_bucket_arn" {
  description = "ARN of the site bucket."
  value       = aws_s3_bucket.site.arn
}

output "site_website_endpoint" {
  description = "S3 static website endpoint (only when enable_public_website=true)."
  value       = var.enable_public_website ? aws_s3_bucket_website_configuration.site[0].website_endpoint : null
}

output "artifacts_bucket_name" {
  description = "S3 bucket name for CI/CD artifacts (built site output)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifacts_bucket_arn" {
  description = "ARN of the artifacts bucket."
  value       = aws_s3_bucket.artifacts.arn
}
