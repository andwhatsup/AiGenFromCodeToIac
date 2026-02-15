output "mlflow_artifact_bucket" {
  description = "S3 bucket used for MLflow artifacts"
  value       = aws_s3_bucket.mlflow_artifacts.bucket
}

output "mlflow_ecr_repository_url" {
  description = "ECR repository URL for MLflow Docker image"
  value       = aws_ecr_repository.mlflow.repository_url
}

output "mlflow_ecs_service_url" {
  description = "MLflow service endpoint (ALB DNS)"
  value       = aws_lb.mlflow.dns_name
}
