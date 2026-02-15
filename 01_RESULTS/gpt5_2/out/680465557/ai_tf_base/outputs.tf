output "lambda_function_name" {
  value       = aws_lambda_function.this.function_name
  description = "Deployed Lambda function name"
}

output "eventbridge_rule_name" {
  value       = aws_cloudwatch_event_rule.schedule.name
  description = "EventBridge schedule rule name"
}

output "iam_role_arn" {
  value       = aws_iam_role.lambda.arn
  description = "IAM role assumed by the Lambda"
}
