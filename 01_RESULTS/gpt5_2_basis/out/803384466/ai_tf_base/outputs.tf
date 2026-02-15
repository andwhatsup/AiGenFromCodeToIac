output "aws_region" {
  value       = var.aws_region
  description = "AWS region"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.app.repository_url
  description = "Push your built Docker image to this ECR repository URL"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.this.arn
  description = "ECS task definition ARN"
}
