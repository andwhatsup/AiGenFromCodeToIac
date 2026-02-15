output "dynamodb_table_name" {
  description = "DynamoDB table used to store processed announcements"
  value       = aws_dynamodb_table.announcements.name
}

output "sns_topic_arn" {
  description = "SNS topic used for fan-out notifications"
  value       = aws_sns_topic.notifications.arn
}

output "check_announcement_lambda_arn" {
  value = aws_lambda_function.check_announcement.arn
}

output "send_notification_lambda_arn" {
  value = aws_lambda_function.send_notification.arn
}

output "send_telegram_notification_lambda_arn" {
  value = aws_lambda_function.send_telegram_notification.arn
}
