output "ecr_repository_url" {
  description = "ECR repository URL to push the Docker image to"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "service_security_group_id" {
  value = aws_security_group.service.id
}
