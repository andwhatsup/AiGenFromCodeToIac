output "artifact_bucket_name" {
  description = "S3 bucket used for MLflow artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL (push your image with tag :latest)"
  value       = aws_ecr_repository.app.repository_url
}

output "apprunner_service_url" {
  description = "App Runner service URL"
  value       = aws_apprunner_service.mlflow.service_url
}

output "db_endpoint" {
  description = "RDS cluster endpoint"
  value       = aws_rds_cluster.mlflow.endpoint
}
