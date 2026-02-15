output "artifacts_bucket_name" {
  description = "S3 bucket for build artifacts/static assets"
  value       = aws_s3_bucket.artifacts.bucket
}

output "iam_role_name" {
  description = "IAM role stub that could be used by compute (e.g., EC2/ECS task role with adjustments)"
  value       = aws_iam_role.app.name
}
