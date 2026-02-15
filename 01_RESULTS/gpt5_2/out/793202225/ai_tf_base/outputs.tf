output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "log_group_name" {
  value       = aws_cloudwatch_log_group.app.name
  description = "CloudWatch log group"
}
