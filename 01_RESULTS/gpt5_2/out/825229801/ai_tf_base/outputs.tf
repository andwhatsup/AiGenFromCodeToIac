output "s3_bucket_name" {
  description = "S3 bucket name for hosting or storing the static site artifacts."
  value       = aws_s3_bucket.site.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.site.arn
}
