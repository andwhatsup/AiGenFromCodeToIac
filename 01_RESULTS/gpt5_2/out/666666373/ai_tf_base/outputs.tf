output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = aws_ecs_service.app.name
  description = "ECS service name"
}

output "task_definition_arn" {
  value       = aws_ecs_task_definition.app.arn
  description = "Task definition ARN"
}

output "security_group_id" {
  value       = aws_security_group.app.id
  description = "Security group ID"
}

output "artifacts_bucket_name" {
  value       = aws_s3_bucket.artifacts.bucket
  description = "S3 bucket for artifacts"
}
