output "s3_bucket_name" {
  description = "S3 bucket for application artifacts"
  value       = aws_s3_bucket.app_artifacts.bucket
}
