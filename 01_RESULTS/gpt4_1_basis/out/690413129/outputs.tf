output "mlflow_artifact_bucket" {
  description = "S3 bucket for MLflow artifacts."
  value       = aws_s3_bucket.mlflow_artifacts.bucket
}

output "mlflow_artifact_bucket_arn" {
  description = "ARN of the S3 bucket for MLflow artifacts."
  value       = aws_s3_bucket.mlflow_artifacts.arn
}
