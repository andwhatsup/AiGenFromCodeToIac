output "s3_bucket_name" {
  description = "S3 bucket for build artifacts / static site assets"
  value       = aws_s3_bucket.site.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.site.arn
}
