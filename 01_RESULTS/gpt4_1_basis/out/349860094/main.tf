resource "aws_dynamodb_table" "announcements" {
  name         = "${var.app_name}-announcements"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "url"

  attribute {
    name = "url"
    type = "S"
  }

  tags = {
    App = var.app_name
  }
}

resource "aws_sns_topic" "notifications" {
  name = "${var.app_name}-notifications"
  tags = {
    App = var.app_name
  }
}

resource "aws_ssm_parameter" "telegram_auth_token" {
  name  = "/${var.app_name}/telegram_auth_token"
  type  = "SecureString"
  value = var.telegram_auth_token
}

module "lambda_check_announcement" {
  source        = "../deploy/modules/lambda"
  prefix        = var.app_name
  function_name = "${var.app_name}-check-announcement"
  description   = "Checks for new announcements."
  handler       = "main"
  runtime       = "go1.x"
  variables = {
    TABLE_NAME = aws_dynamodb_table.announcements.name
    SNS_TOPIC  = aws_sns_topic.notifications.arn
  }
}

module "lambda_send_notification" {
  source        = "../deploy/modules/lambda"
  prefix        = var.app_name
  function_name = "${var.app_name}-send-notification"
  description   = "Publishes new announcements to SNS."
  handler       = "main"
  runtime       = "go1.x"
  variables = {
    TABLE_NAME = aws_dynamodb_table.announcements.name
    SNS_TOPIC  = aws_sns_topic.notifications.arn
  }
}

module "lambda_send_telegram_notification" {
  source        = "../deploy/modules/lambda"
  prefix        = var.app_name
  function_name = "${var.app_name}-send-telegram-notification"
  description   = "Sends notifications to Telegram."
  handler       = "main"
  runtime       = "go1.x"
  variables = {
    TELEGRAM_AUTH_TOKEN = aws_ssm_parameter.telegram_auth_token.value
    SNS_TOPIC           = aws_sns_topic.notifications.arn
  }
}

resource "aws_cloudwatch_event_rule" "check_announcement" {
  name                = "${var.app_name}-check-announcement-schedule"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "check_announcement" {
  rule      = aws_cloudwatch_event_rule.check_announcement.name
  arn       = module.lambda_check_announcement.arn
}
