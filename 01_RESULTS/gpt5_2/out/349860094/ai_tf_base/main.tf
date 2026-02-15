data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Provider v6 deprecates aws_region.current.name in favor of .id
locals {
  region_name = data.aws_region.current.id
}

locals {
  name_prefix = var.app_name
}

# -----------------------------
# DynamoDB (state of last announcement)
# -----------------------------
resource "aws_dynamodb_table" "announcements" {
  name         = "${local.name_prefix}-announcements"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "URL"

  attribute {
    name = "URL"
    type = "S"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}

# -----------------------------
# SNS topic (fan-out)
# -----------------------------
resource "aws_sns_topic" "notifications" {
  name = "${local.name_prefix}-notifications"
}

# -----------------------------
# SSM parameters
# -----------------------------
resource "aws_ssm_parameter" "telegram_auth_token" {
  name        = "/telegram/auth_token"
  description = "Telegram bot auth token"
  type        = "SecureString"
  value       = var.telegram_auth_token
}

resource "aws_ssm_parameter" "telegram_chat_id" {
  for_each    = var.announcements
  name        = "/announcements/telegram/${each.key}/chat_id"
  description = "Telegram chat id for announcement ${each.key}"
  type        = "String"
  value       = each.value.telegram_chat_id
}

resource "aws_ssm_parameter" "telegram_channel_name" {
  for_each    = var.announcements
  name        = "/announcements/telegram/${each.key}/channel_name"
  description = "Telegram channel name for announcement ${each.key}"
  type        = "String"
  value       = each.value.telegram_channel_name
}

# -----------------------------
# Lambda packaging (placeholder)
# -----------------------------
# This repository contains Go lambda code, but building binaries is out of scope
# for this minimal IaC. We deploy placeholder zip files so Terraform validates.
# Replace these with real build artifacts (e.g., via CI) when applying.

data "archive_file" "check_announcement_zip" {
  type        = "zip"
  output_path = "${path.module}/artifacts/check_announcement.zip"

  source {
    content  = "placeholder"
    filename = "bootstrap"
  }
}

data "archive_file" "send_notification_zip" {
  type        = "zip"
  output_path = "${path.module}/artifacts/send_notification.zip"

  source {
    content  = "placeholder"
    filename = "bootstrap"
  }
}

data "archive_file" "send_telegram_notification_zip" {
  type        = "zip"
  output_path = "${path.module}/artifacts/send_telegram_notification.zip"

  source {
    content  = "placeholder"
    filename = "bootstrap"
  }
}

# -----------------------------
# IAM
# -----------------------------

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "check_announcement" {
  name               = "${local.name_prefix}-check-announcement"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "send_notification" {
  name               = "${local.name_prefix}-send-notification"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role" "send_telegram_notification" {
  name               = "${local.name_prefix}-send-telegram-notification"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "check_announcement_basic" {
  role       = aws_iam_role.check_announcement.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "send_notification_basic" {
  role       = aws_iam_role.send_notification.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "send_telegram_notification_basic" {
  role       = aws_iam_role.send_telegram_notification.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "check_announcement_policy" {
  statement {
    sid     = "DynamoDBReadWrite"
    effect  = "Allow"
    actions = ["dynamodb:GetItem", "dynamodb:PutItem"]
    resources = [
      aws_dynamodb_table.announcements.arn
    ]
  }
}

resource "aws_iam_policy" "check_announcement" {
  name   = "${local.name_prefix}-check-announcement"
  policy = data.aws_iam_policy_document.check_announcement_policy.json
}

resource "aws_iam_role_policy_attachment" "check_announcement_policy" {
  role       = aws_iam_role.check_announcement.name
  policy_arn = aws_iam_policy.check_announcement.arn
}

data "aws_iam_policy_document" "send_notification_policy" {
  statement {
    sid     = "SNSPublish"
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = [
      aws_sns_topic.notifications.arn
    ]
  }
}

resource "aws_iam_policy" "send_notification" {
  name   = "${local.name_prefix}-send-notification"
  policy = data.aws_iam_policy_document.send_notification_policy.json
}

resource "aws_iam_role_policy_attachment" "send_notification_policy" {
  role       = aws_iam_role.send_notification.name
  policy_arn = aws_iam_policy.send_notification.arn
}

data "aws_iam_policy_document" "send_telegram_notification_policy" {
  statement {
    sid     = "SSMRead"
    effect  = "Allow"
    actions = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParametersByPath"]
    resources = [
      aws_ssm_parameter.telegram_auth_token.arn,
      "arn:aws:ssm:${local.region_name}:${data.aws_caller_identity.current.account_id}:parameter/announcements/telegram/*",
      "arn:aws:ssm:${local.region_name}:${data.aws_caller_identity.current.account_id}:parameter/telegram/auth_token"
    ]
  }
}

resource "aws_iam_policy" "send_telegram_notification" {
  name   = "${local.name_prefix}-send-telegram-notification"
  policy = data.aws_iam_policy_document.send_telegram_notification_policy.json
}

resource "aws_iam_role_policy_attachment" "send_telegram_notification_policy" {
  role       = aws_iam_role.send_telegram_notification.name
  policy_arn = aws_iam_policy.send_telegram_notification.arn
}

# -----------------------------
# Lambdas
# -----------------------------
resource "aws_lambda_function" "check_announcement" {
  function_name = "${local.name_prefix}-check-announcement"
  description   = "Checks if a new announcement has been published and stores it in DynamoDB"
  role          = aws_iam_role.check_announcement.arn

  runtime       = "provided.al2"
  handler       = "bootstrap"
  architectures = ["x86_64"]

  filename         = data.archive_file.check_announcement_zip.output_path
  source_code_hash = data.archive_file.check_announcement_zip.output_base64sha256

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.announcements.name
      BASE_URL       = var.base_url
      DATE_FORMAT    = var.date_format
    }
  }
}

resource "aws_lambda_function" "send_notification" {
  function_name = "${local.name_prefix}-send-notification"
  description   = "Triggered by DynamoDB stream and publishes to SNS"
  role          = aws_iam_role.send_notification.arn

  runtime       = "provided.al2"
  handler       = "bootstrap"
  architectures = ["x86_64"]

  filename         = data.archive_file.send_notification_zip.output_path
  source_code_hash = data.archive_file.send_notification_zip.output_base64sha256

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.notifications.arn
    }
  }
}

resource "aws_lambda_function" "send_telegram_notification" {
  function_name = "${local.name_prefix}-send-telegram-notification"
  description   = "Triggered by SNS and sends the announcement to Telegram"
  role          = aws_iam_role.send_telegram_notification.arn

  runtime       = "provided.al2"
  handler       = "bootstrap"
  architectures = ["x86_64"]

  filename         = data.archive_file.send_telegram_notification_zip.output_path
  source_code_hash = data.archive_file.send_telegram_notification_zip.output_base64sha256

  timeout     = 30
  memory_size = 256

  environment {
    variables = {
      SSM_TELEGRAM_AUTH_TOKEN   = aws_ssm_parameter.telegram_auth_token.name
      SSM_TELEGRAM_CHAT_ID      = "/announcements/telegram/%s/chat_id"
      SSM_TELEGRAM_CHANNEL_NAME = "/announcements/telegram/%s/channel_name"
    }
  }
}

# -----------------------------
# EventBridge schedule -> check_announcement
# -----------------------------
resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.name_prefix}-check-announcement"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "schedule_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "check-announcement"
  arn       = aws_lambda_function.check_announcement.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_announcement.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

# -----------------------------
# DynamoDB stream -> send_notification
# -----------------------------
resource "aws_lambda_event_source_mapping" "dynamodb_to_send_notification" {
  event_source_arn  = aws_dynamodb_table.announcements.stream_arn
  function_name     = aws_lambda_function.send_notification.arn
  starting_position = "LATEST"
}

# -----------------------------
# SNS -> send_telegram_notification
# -----------------------------
resource "aws_sns_topic_subscription" "telegram_lambda" {
  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.send_telegram_notification.arn
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_telegram_notification.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.notifications.arn
}
