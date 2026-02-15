output "dynamodb_table_name" {
  value = aws_dynamodb_table.announcements.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.announcements.arn
}

output "lambda_check_announcement_arn" {
  value = aws_lambda_function.check_announcement.arn
}

output "lambda_send_notification_arn" {
  value = aws_lambda_function.send_notification.arn
}

output "lambda_send_telegram_notification_arn" {
  value = aws_lambda_function.send_telegram_notification.arn
}
