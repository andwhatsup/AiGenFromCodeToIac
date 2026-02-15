output "bucket_name" {
  description = "Name of the S3 bucket hosting the static site."
  value       = aws_s3_bucket.static_site.bucket
}

output "website_endpoint" {
  description = "S3 static website endpoint URL."
  value       = aws_s3_bucket.static_site.website_endpoint
}
