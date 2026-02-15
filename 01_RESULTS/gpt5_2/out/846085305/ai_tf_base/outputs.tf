output "aws_region" {
  description = "AWS region in use."
  value       = var.aws_region
}

output "ecr_repository_url" {
  description = "ECR repository URL to push the Lambda container image to."
  value       = aws_ecr_repository.app.repository_url
}

output "lambda_function_name" {
  description = "Deployed Lambda function name."
  value       = aws_lambda_function.collector.function_name
}

output "eventbridge_rule_name" {
  description = "EventBridge schedule rule name."
  value       = aws_cloudwatch_event_rule.schedule.name
}
