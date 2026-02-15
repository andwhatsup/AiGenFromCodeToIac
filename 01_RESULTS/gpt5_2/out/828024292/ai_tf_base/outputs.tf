output "s3_bucket_name" {
  description = "Name of the S3 bucket created for the app."
  value       = aws_s3_bucket.app.bucket
}

output "aws_region" {
  description = "AWS region used by the provider."
  value       = var.aws_region
}
