output "ecr_repository_url" {
  description = "ECR repository URL to push the epicac container image to"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.app.arn
}

output "artifacts_bucket_name" {
  description = "S3 bucket for artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}
