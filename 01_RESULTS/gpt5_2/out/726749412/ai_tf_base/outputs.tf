output "aws_region" {
  description = "Region in which resources were created."
  value       = var.aws_region
}

output "artifacts_bucket_name" {
  description = "S3 bucket for build artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "runtime_role_arn" {
  description = "IAM role ARN that can be used by a future ECS task/Lambda runtime."
  value       = aws_iam_role.app_runtime.arn
}
