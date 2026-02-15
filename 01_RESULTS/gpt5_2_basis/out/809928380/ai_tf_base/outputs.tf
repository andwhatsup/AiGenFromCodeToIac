output "aws_account_id" {
  description = "AWS account id."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used by the provider."
  value       = data.aws_region.current.name
}

output "lambda_function_name" {
  description = "Deployed Lambda function name."
  value       = aws_lambda_function.this.function_name
}

output "event_rule_name" {
  description = "EventBridge rule name that triggers the Lambda."
  value       = aws_cloudwatch_event_rule.daily.name
}
