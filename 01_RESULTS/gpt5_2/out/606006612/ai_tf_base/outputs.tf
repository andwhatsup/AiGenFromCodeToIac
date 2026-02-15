output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group for container logs"
  value       = aws_cloudwatch_log_group.app.name
}

output "default_vpc_id" {
  description = "Default VPC used when subnet_ids not provided"
  value       = data.aws_vpc.default.id
}
