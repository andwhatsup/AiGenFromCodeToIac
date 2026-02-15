output "aws_region" {
  description = "AWS region in use."
  value       = var.aws_region
}

output "artifacts_bucket_name" {
  description = "S3 bucket for artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "app_role_arn" {
  description = "IAM role ARN stub for future compute (ECS tasks/Lambda)."
  value       = aws_iam_role.app.arn
}
