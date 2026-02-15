output "lambda_function_name" {
  description = "Name of the deployed Lambda function."
  value       = aws_lambda_function.app_lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN of the deployed Lambda function."
  value       = aws_lambda_function.app_lambda.arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for Lambda image."
  value       = aws_ecr_repository.lambda_repo.repository_url
}
