data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix = var.app_name

  # SSM parameter naming convention used by the application code
  ssm_auth_token_name = "/telegram/auth_token"

  # Per-announcement parameters are stored under:
  # /announcements/telegram/<announcement_id>/chat_id
  # /announcements/telegram/<announcement_id>/channel_name
  announcement_param_prefix = "/announcements/telegram"
}

# -----------------------------
# DynamoDB (state)
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
# SNS (fan-out)
# -----------------------------
resource "aws_sns_topic" "notifications" {
  name = "${local.name_prefix}-notifications"
}

# -----------------------------
# SSM Parameters
# -----------------------------
resource "aws_ssm_parameter" "telegram_auth_token" {
  name        = local.ssm_auth_token_name
  description = "Telegram bot auth token"
  type        = "SecureString"
  value       = var.telegram_auth_token
}

resource "aws_ssm_parameter" "telegram_chat_id" {
  for_each    = var.announcements
  name        = "${local.announcement_param_prefix}/${each.key}/chat_id"
  description = "Telegram chat id for announcement ${each.key}"
  type        = "String"
  value       = each.value.telegram_chat_id
}

resource "aws_ssm_parameter" "telegram_channel_name" {
  for_each    = var.announcements
  name        = "${local.announcement_param_prefix}/${each.key}/channel_name"
  description = "Telegram channel name for announcement ${each.key}"
  type        = "String"
  value       = each.value.telegram_channel_name
}

# -----------------------------
# IAM + Lambda
# -----------------------------

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
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

# Basic logging for all lambdas
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  for_each = {
    check = aws_iam_role.check_announcement.name
    sendn = aws_iam_role.send_notification.name
    sendt = aws_iam_role.send_telegram_notification.name
  }

  role       = each.value
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permissions: check_announcement -> DynamoDB Put/Get
data "aws_iam_policy_document" "check_announcement" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
    ]
    resources = [aws_dynamodb_table.announcements.arn]
  }
}

resource "aws_iam_policy" "check_announcement" {
  name   = "${local.name_prefix}-check-announcement"
  policy = data.aws_iam_policy_document.check_announcement.json
}

resource "aws_iam_role_policy_attachment" "check_announcement" {
  role       = aws_iam_role.check_announcement.name
  policy_arn = aws_iam_policy.check_announcement.arn
}

# Permissions: send_notification -> SNS publish
data "aws_iam_policy_document" "send_notification" {
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [aws_sns_topic.notifications.arn]
  }
}

resource "aws_iam_policy" "send_notification" {
  name   = "${local.name_prefix}-send-notification"
  policy = data.aws_iam_policy_document.send_notification.json
}

resource "aws_iam_role_policy_attachment" "send_notification" {
  role       = aws_iam_role.send_notification.name
  policy_arn = aws_iam_policy.send_notification.arn
}

# Permissions: send_telegram_notification -> SSM get parameters
data "aws_iam_policy_document" "send_telegram_notification" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = [
      "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.ssm_auth_token_name}",
      "arn:${data.aws_partition.current.partition}:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.announcement_param_prefix}/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "send_telegram_notification" {
  name   = "${local.name_prefix}-send-telegram-notification"
  policy = data.aws_iam_policy_document.send_telegram_notification.json
}

resource "aws_iam_role_policy_attachment" "send_telegram_notification" {
  role       = aws_iam_role.send_telegram_notification.name
  policy_arn = aws_iam_policy.send_telegram_notification.arn
}

# -----------------------------
# Lambda functions
# -----------------------------

# Minimal placeholder packages so terraform validates without requiring build artifacts.
# Replace these with real deployment packages (zip) in a CI pipeline.
resource "aws_lambda_function" "check_announcement" {
  function_name = "${local.name_prefix}-check-announcement"
  role          = aws_iam_role.check_announcement.arn
  handler       = "main"
  runtime       = "go1.x"
  timeout       = 10
  memory_size   = 128

  filename         = local.lambda_dummy_zip
  source_code_hash = data.archive_file.lambda_dummy.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.announcements.name
      BASE_URL       = var.base_url
      DATE_FORMAT    = var.date_format
    }
  }

  depends_on = [aws_cloudwatch_log_group.check_announcement]
}

resource "aws_lambda_function" "send_notification" {
  function_name = "${local.name_prefix}-send-notification"
  role          = aws_iam_role.send_notification.arn
  handler       = "main"
  runtime       = "go1.x"
  timeout       = 10
  memory_size   = 128

  filename         = local.lambda_dummy_zip
  source_code_hash = data.archive_file.lambda_dummy.output_base64sha256

  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.notifications.arn
    }
  }

  depends_on = [aws_cloudwatch_log_group.send_notification]
}

resource "aws_lambda_function" "send_telegram_notification" {
  function_name = "${local.name_prefix}-send-telegram-notification"
  role          = aws_iam_role.send_telegram_notification.arn
  handler       = "main"
  runtime       = "go1.x"
  timeout       = 30
  memory_size   = 256

  filename         = local.lambda_dummy_zip
  source_code_hash = data.archive_file.lambda_dummy.output_base64sha256

  environment {
    variables = {
      SSM_TELEGRAM_AUTH_TOKEN   = aws_ssm_parameter.telegram_auth_token.name
      SSM_TELEGRAM_CHAT_ID      = "${local.announcement_param_prefix}/{announcement_id}/chat_id"
      SSM_TELEGRAM_CHANNEL_NAME = "${local.announcement_param_prefix}/{announcement_id}/channel_name"
    }
  }

  depends_on = [aws_cloudwatch_log_group.send_telegram_notification]
}

# Log groups (explicit so we can set retention)
resource "aws_cloudwatch_log_group" "check_announcement" {
  name              = "/aws/lambda/${local.name_prefix}-check-announcement"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "send_notification" {
  name              = "/aws/lambda/${local.name_prefix}-send-notification"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "send_telegram_notification" {
  name              = "/aws/lambda/${local.name_prefix}-send-telegram-notification"
  retention_in_days = 14
}

# -----------------------------
# EventBridge schedule -> check_announcement
# -----------------------------
resource "aws_cloudwatch_event_rule" "check_announcement" {
  name                = "${local.name_prefix}-check-announcement"
  schedule_expression = var.schedule_expression
}

# One target per announcement ID (passed as input)
resource "aws_cloudwatch_event_target" "check_announcement" {
  for_each = var.announcements

  rule      = aws_cloudwatch_event_rule.check_announcement.name
  target_id = "announcement-${each.key}"
  arn       = aws_lambda_function.check_announcement.arn

  input = jsonencode({
    AnnouncementID = each.key
  })
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = var.announcements

  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.check_announcement.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.check_announcement.arn
}

# -----------------------------
# DynamoDB stream -> send_notification
# -----------------------------
resource "aws_lambda_event_source_mapping" "dynamodb_to_send_notification" {
  event_source_arn  = aws_dynamodb_table.announcements.stream_arn
  function_name     = aws_lambda_function.send_notification.arn
  starting_position = "LATEST"

  depends_on = [aws_lambda_permission.allow_dynamodb_stream]
}

resource "aws_lambda_permission" "allow_dynamodb_stream" {
  statement_id  = "AllowExecutionFromDynamoDBStream"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.send_notification.function_name
  principal     = "dynamodb.amazonaws.com"
  source_arn    = aws_dynamodb_table.announcements.stream_arn
}

# -----------------------------
# SNS -> send_telegram_notification
# -----------------------------
resource "aws_sns_topic_subscription" "send_telegram_notification" {
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
