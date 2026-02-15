output "ecr_repository_url" {
  description = "ECR repository URL to push the Docker image to."
  value       = aws_ecr_repository.app.repository_url
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group name for application logs (if you later run ECS tasks)."
  value       = aws_cloudwatch_log_group.app.name
}
