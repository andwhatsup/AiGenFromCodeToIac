output "aws_account_id" {
  description = "AWS account ID."
  value       = data.aws_caller_identity.current.account_id
}

output "region" {
  description = "AWS region used."
  value       = data.aws_region.current.name
}

output "artifact_bucket_name" {
  description = "S3 bucket for build artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL to push the Docker image to."
  value       = aws_ecr_repository.app.repository_url
}
