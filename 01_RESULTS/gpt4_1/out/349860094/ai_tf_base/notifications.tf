resource "aws_lambda_permission" "allow_dynamodb_to_invoke_send_notification" {
  statement_id  = "AllowExecutionFromDynamoDB"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_notification.function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = aws_dynamodb_table.announcements.stream_arn
}

resource "aws_lambda_event_source_mapping" "dynamodb_to_send_notification" {
  event_source_arn  = aws_dynamodb_table.announcements.stream_arn
  function_name     = aws_lambda_function.send_notification.arn
  starting_position = "LATEST"
}

resource "aws_lambda_permission" "allow_sns_to_invoke_send_telegram_notification" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_telegram_notification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.announcements.arn
}

resource "aws_sns_topic_subscription" "telegram_lambda" {
  topic_arn = aws_sns_topic.announcements.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.send_telegram_notification.arn
}
