resource "aws_cloudwatch_event_rule" "check_announcement_schedule" {
  name                = "${var.app_name}-check-announcement-schedule"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "check_announcement_lambda" {
  rule      = aws_cloudwatch_event_rule.check_announcement_schedule.name
  target_id = "check-announcement-lambda"
  arn       = aws_lambda_function.check_announcement.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_check_announcement" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_announcement.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.check_announcement_schedule.arn
}
