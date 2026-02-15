output "artifacts_bucket_name" {
  description = "Name of the S3 bucket created for artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "aws_region" {
  value = var.aws_region
}
