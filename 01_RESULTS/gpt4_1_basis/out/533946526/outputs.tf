output "s3_bucket_name" {
  description = "Name of the S3 bucket for artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}

output "iam_role_name" {
  description = "Name of the IAM role for the app."
  value       = aws_iam_role.app.name
}
