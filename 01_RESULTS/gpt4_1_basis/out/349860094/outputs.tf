output "dynamodb_table_name" {
  value = aws_dynamodb_table.announcements.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.notifications.arn
}

output "lambda_check_announcement_arn" {
  value = module.lambda_check_announcement.arn
}

output "lambda_send_notification_arn" {
  value = module.lambda_send_notification.arn
}

output "lambda_send_telegram_notification_arn" {
  value = module.lambda_send_telegram_notification.arn
}
