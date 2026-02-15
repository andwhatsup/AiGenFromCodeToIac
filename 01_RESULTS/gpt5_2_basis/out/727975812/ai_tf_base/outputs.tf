output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.venmo.function_name
}

output "lambda_function_arn" {
  description = "Deployed Lambda function ARN"
  value       = aws_lambda_function.venmo.arn
}

output "eventbridge_rule_names" {
  description = "Names of created EventBridge schedule rules"
  value       = [for r in aws_cloudwatch_event_rule.schedule : r.name]
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alarms (null if alarm_email not set)"
  value       = var.alarm_email == null ? null : aws_sns_topic.alarms[0].arn
}
