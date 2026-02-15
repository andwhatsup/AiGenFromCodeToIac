output "artifact_bucket_name" {
  description = "S3 bucket for build artifacts / static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL to push the Docker image to."
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_task_execution_role_arn" {
  description = "IAM role ARN for ECS task execution (useful if later adding ECS/Fargate)."
  value       = aws_iam_role.ecs_task_execution.arn
}
