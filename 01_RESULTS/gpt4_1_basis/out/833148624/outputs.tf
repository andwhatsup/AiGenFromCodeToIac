output "s3_bucket_name" {
  description = "Name of the S3 bucket for artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}
