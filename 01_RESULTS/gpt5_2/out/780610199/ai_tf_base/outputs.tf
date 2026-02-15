output "ecr_repository_url" {
  description = "ECR repository URL to push the application image to (tag :latest)."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.app.name
}

output "task_security_group_id" {
  value = aws_security_group.task.id
}
