output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "task_execution_role_arn" {
  value       = aws_iam_role.task_execution.arn
  description = "IAM role used by ECS task execution"
}

output "security_group_id" {
  value       = aws_security_group.service.id
  description = "Security group attached to the service"
}
