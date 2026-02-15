output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static site"
  value       = aws_s3_bucket.static_site.bucket
}

output "s3_bucket_website_url" {
  description = "Website endpoint of the S3 bucket"
  value       = aws_s3_bucket.static_site.website_endpoint
}
