output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the static site"
  value       = try(aws_s3_bucket.site[0].bucket, null)
}

output "s3_website_endpoint" {
  description = "S3 static website endpoint (HTTP)"
  value       = try(aws_s3_bucket_website_configuration.site[0].website_endpoint, null)
}
