output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static site"
  value       = aws_s3_bucket.site.bucket
}

output "website_endpoint" {
  description = "S3 static website endpoint (HTTP)"
  value       = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "website_domain" {
  description = "S3 static website domain"
  value       = aws_s3_bucket_website_configuration.site.website_domain
}
