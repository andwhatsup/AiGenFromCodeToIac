output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "lambda_function_arn" {
  description = "Deployed Lambda function ARN"
  value       = aws_lambda_function.this.arn
}

output "event_rule_name" {
  description = "EventBridge rule name"
  value       = aws_cloudwatch_event_rule.schedule.name
}

output "aws_account_id" {
  description = "AWS account id"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.region
}
