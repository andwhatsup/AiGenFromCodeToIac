output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "task_security_group_id" {
  value       = aws_security_group.task.id
  description = "Security group attached to the tasks"
}

output "default_vpc_id" {
  value       = data.aws_vpc.default.id
  description = "Default VPC used"
}
