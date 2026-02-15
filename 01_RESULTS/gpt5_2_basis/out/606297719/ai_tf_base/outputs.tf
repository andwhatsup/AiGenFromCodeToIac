output "s3_bucket_name" {
  description = "S3 bucket name for Prefect flow storage/artifacts"
  value       = aws_s3_bucket.prefect_storage.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.prefect_storage.arn
}
