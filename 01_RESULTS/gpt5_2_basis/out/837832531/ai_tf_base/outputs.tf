output "s3_bucket_name" {
  description = "Name of the S3 bucket created for app artifacts/static assets."
  value       = aws_s3_bucket.site.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket created for app artifacts/static assets."
  value       = aws_s3_bucket.site.arn
}
