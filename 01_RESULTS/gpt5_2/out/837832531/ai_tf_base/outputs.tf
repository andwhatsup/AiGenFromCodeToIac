output "s3_bucket_name" {
  description = "S3 bucket name for hosting static assets"
  value       = aws_s3_bucket.static.bucket
}

output "s3_website_endpoint" {
  description = "S3 static website endpoint (note: bucket is not public by default)"
  value       = aws_s3_bucket_website_configuration.static.website_endpoint
}
