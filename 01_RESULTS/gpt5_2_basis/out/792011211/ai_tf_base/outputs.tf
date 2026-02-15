output "artifacts_bucket_name" {
  description = "S3 bucket for build artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "api_key_secret_arn" {
  description = "ARN of the Secrets Manager secret used for the OpenWeatherMap API key."
  value       = var.manage_api_key_secret ? aws_secretsmanager_secret.api_key[0].arn : data.aws_secretsmanager_secret.api_key[0].arn
}
