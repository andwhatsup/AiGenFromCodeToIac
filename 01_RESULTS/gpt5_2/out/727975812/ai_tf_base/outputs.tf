output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "scheduler_schedule_names" {
  description = "Names of created EventBridge Scheduler schedules"
  value       = [for s in aws_scheduler_schedule.venmo : s.name]
}

output "sns_topic_arn" {
  description = "SNS topic ARN for alarms"
  value       = aws_sns_topic.alarms.arn
}
