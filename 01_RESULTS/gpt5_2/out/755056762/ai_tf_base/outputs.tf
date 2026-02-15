output "s3_bucket_name" {
  description = "Name of the S3 bucket intended to receive ingested data"
  value       = aws_s3_bucket.data.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.data.arn
}
