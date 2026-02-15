output "artifact_bucket_name" {
  description = "S3 bucket for build artifacts (e.g., React build output)"
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL to push the Docker image"
  value       = aws_ecr_repository.app.repository_url
}
