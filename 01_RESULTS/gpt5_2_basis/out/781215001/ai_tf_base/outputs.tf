output "db_endpoint" {
  description = "RDS endpoint address."
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "RDS port."
  value       = aws_db_instance.postgres.port
}

output "database_url" {
  description = "Convenience DATABASE_URL for the app (Prisma)."
  value       = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${var.db_name}"
  sensitive   = true
}

output "artifacts_bucket_name" {
  description = "S3 bucket for artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}
