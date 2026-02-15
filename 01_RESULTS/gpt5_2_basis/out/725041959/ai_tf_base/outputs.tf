output "artifact_bucket_name" {
  description = "S3 bucket name for artifacts/backups."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "S3 bucket ARN for artifacts/backups."
  value       = aws_s3_bucket.artifacts.arn
}

output "iam_task_role_arn" {
  description = "IAM role ARN (stub) that can be used by a scheduled container task."
  value       = aws_iam_role.task_role.arn
}
