output "s3_bucket_name" {
  description = "S3 bucket for hosting/build artifacts."
  value       = aws_s3_bucket.site.bucket
}

output "s3_website_endpoint" {
  description = "S3 static website endpoint (note: bucket is private unless you add a public policy or CloudFront)."
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
}
