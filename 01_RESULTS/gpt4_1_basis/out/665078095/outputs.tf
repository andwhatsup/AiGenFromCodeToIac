output "rds_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.app_db.endpoint
}

output "rds_db_name" {
  description = "The database name."
  value       = aws_db_instance.app_db.db_name
}
