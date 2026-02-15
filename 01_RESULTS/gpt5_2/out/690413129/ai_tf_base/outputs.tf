output "artifact_bucket_name" {
  description = "S3 bucket for MLflow artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the S3 bucket for MLflow artifacts"
  value       = aws_s3_bucket.artifacts.arn
}

output "app_iam_role_arn" {
  description = "IAM role that can be assumed by a compute service (App Runner/ECS tasks)"
  value       = aws_iam_role.app.arn
}

output "mlflow_artifact_uri" {
  description = "MLflow artifact URI to configure in the service"
  value       = "s3://${aws_s3_bucket.artifacts.bucket}"
}
