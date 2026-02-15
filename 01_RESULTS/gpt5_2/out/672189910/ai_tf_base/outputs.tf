output "artifacts_bucket_name" {
  description = "S3 bucket for artifacts/static assets"
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL to push the Streamlit container image"
  value       = aws_ecr_repository.app.repository_url
}
