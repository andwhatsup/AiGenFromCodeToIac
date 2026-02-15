output "s3_bucket_name" {
  description = "Name of the S3 bucket used by the application"
  value       = aws_s3_bucket.app.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used by the application"
  value       = aws_s3_bucket.app.arn
}

output "s3_versioning_status" {
  description = "S3 versioning status"
  value       = aws_s3_bucket_versioning.app.versioning_configuration[0].status
}
