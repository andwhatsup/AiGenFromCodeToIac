output "db_endpoint" {
  description = "RDS endpoint address (host:port)."
  value       = aws_db_instance.mysql.endpoint
}

output "db_address" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.mysql.address
}

output "db_port" {
  description = "RDS port."
  value       = aws_db_instance.mysql.port
}

output "db_name" {
  description = "Database name."
  value       = var.db_name
}
