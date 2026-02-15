output "artifact_bucket_name" {
  description = "S3 bucket for artifacts/backups."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the artifacts bucket."
  value       = aws_s3_bucket.artifacts.arn
}

output "app_role_arn" {
  description = "IAM role ARN intended for future compute (e.g., ECS task role)."
  value       = aws_iam_role.app.arn
}
