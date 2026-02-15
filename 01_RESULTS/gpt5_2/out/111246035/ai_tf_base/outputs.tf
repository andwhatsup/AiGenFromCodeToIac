output "aws_region" {
  value       = var.aws_region
  description = "AWS region in use."
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name."
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name."
}

output "cloudwatch_log_group" {
  value       = aws_cloudwatch_log_group.app.name
  description = "CloudWatch log group for the task."
}
