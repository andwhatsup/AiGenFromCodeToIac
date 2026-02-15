output "artifact_bucket_name" {
  description = "S3 bucket for storing build artifacts/backups"
  value       = aws_s3_bucket.artifacts.bucket
}

output "ssm_parameter_names" {
  description = "SSM Parameter Store names for runtime environment variables"
  value       = [for p in aws_ssm_parameter.env : p.name]
}
