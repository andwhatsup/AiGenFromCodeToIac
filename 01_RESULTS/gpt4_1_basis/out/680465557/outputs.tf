output "lambda_function_name" {
  description = "Name of the deployed Lambda function."
  value       = aws_lambda_function.gitops_lambda.function_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository."
  value       = aws_ecr_repository.gitops_ecr.repository_url
}
