output "ecr_repository_url" {
  description = "ECR repository URL to push the application image"
  value       = aws_ecr_repository.app.repository_url
}

output "apprunner_service_url" {
  description = "Public URL of the App Runner service"
  value       = aws_apprunner_service.app.service_url
}

output "apprunner_ecr_access_role_arn" {
  description = "IAM role ARN used by App Runner to pull from ECR"
  value       = aws_iam_role.apprunner_ecr_access.arn
}
