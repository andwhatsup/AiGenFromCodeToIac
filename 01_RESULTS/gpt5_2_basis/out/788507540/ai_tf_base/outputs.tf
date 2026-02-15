output "artifact_bucket_name" {
  description = "S3 bucket for build artifacts / static assets"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the artifacts bucket"
  value       = aws_s3_bucket.artifacts.arn
}

output "app_runtime_role_arn" {
  description = "IAM role ARN intended for future runtime (ECS task role)"
  value       = aws_iam_role.app_runtime.arn
}
