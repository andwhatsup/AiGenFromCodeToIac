output "artifact_bucket_name" {
  description = "S3 bucket for MLflow artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}

output "ecr_repository_url" {
  description = "ECR repository URL to push the MLflow container image."
  value       = aws_ecr_repository.app.repository_url
}

output "apprunner_role_arn" {
  description = "IAM role ARN intended for App Runner to access S3 artifacts."
  value       = aws_iam_role.apprunner.arn
}
