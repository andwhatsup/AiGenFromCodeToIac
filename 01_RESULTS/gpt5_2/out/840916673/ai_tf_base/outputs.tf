output "static_site_bucket_name" {
  description = "S3 bucket name hosting the static website"
  value       = aws_s3_bucket.static_site.bucket
}

output "static_site_website_endpoint" {
  description = "S3 website endpoint (note: bucket is private; use CloudFront or adjust policy for public access if needed)"
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}
