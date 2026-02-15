output "db_endpoint" {
  description = "RDS endpoint address."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "RDS port."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name."
  value       = var.db_name
}

output "db_username" {
  description = "Database master username."
  value       = var.db_username
}

output "db_password" {
  description = "Database master password (generated)."
  value       = random_password.db.result
  sensitive   = true
}
