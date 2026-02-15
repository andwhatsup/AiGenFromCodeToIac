output "artifact_bucket_name" {
  description = "S3 bucket for build artifacts / container image metadata / static assets"
  value       = aws_s3_bucket.artifacts.bucket
}

output "app_runtime_role_arn" {
  description = "IAM role ARN stub for future runtime (e.g., ECS task role)"
  value       = aws_iam_role.app_runtime.arn
}
