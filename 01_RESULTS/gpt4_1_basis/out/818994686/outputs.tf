output "ecr_repository_url" {
  description = "URL of the ECR repository for the application image."
  value       = aws_ecr_repository.app.repository_url
}

output "rds_endpoint" {
  description = "RDS MySQL endpoint."
  value       = aws_db_instance.mysql.address
}

output "ecs_service_name" {
  description = "ECS Service name."
  value       = aws_ecs_service.app.name
}
