output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "log_group_name" {
  description = "CloudWatch log group for the task."
  value       = aws_cloudwatch_log_group.this.name
}

output "default_vpc_id" {
  description = "Default VPC used for the service."
  value       = data.aws_vpc.default.id
}
