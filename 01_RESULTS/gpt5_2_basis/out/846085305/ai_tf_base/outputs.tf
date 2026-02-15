output "ecr_repository_url" {
  description = "ECR repository URL to push the Lambda container image to."
  value       = aws_ecr_repository.app.repository_url
}

output "lambda_function_name" {
  description = "Deployed Lambda function name."
  value       = aws_lambda_function.app.function_name
}

output "event_rule_name" {
  description = "EventBridge rule that triggers the Lambda."
  value       = aws_cloudwatch_event_rule.schedule.name
}
