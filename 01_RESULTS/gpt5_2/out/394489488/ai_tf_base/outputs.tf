output "artifact_bucket_name" {
  description = "S3 bucket used for MLflow artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}

output "apprunner_service_url" {
  description = "Public URL of the App Runner service."
  value       = aws_apprunner_service.mlflow.service_url
}

output "backend_store_enabled" {
  description = "Whether an RDS backend store was created."
  value       = var.create_backend_store
}

output "rds_endpoint" {
  description = "RDS endpoint (if enabled)."
  value       = var.create_backend_store ? aws_db_instance.mlflow[0].address : null
}
