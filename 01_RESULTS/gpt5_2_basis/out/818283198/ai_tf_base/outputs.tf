output "aws_region" {
  value       = var.aws_region
  description = "AWS region"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.playwright_lambda.repository_url
  description = "ECR repository URL to push the Lambda image to"
}

output "lambda_function_name" {
  value       = aws_lambda_function.playwright.function_name
  description = "Deployed Lambda function name"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.playwright.arn
  description = "Deployed Lambda function ARN"
}
