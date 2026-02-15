locals {
  common_tags = merge(
    {
      Application = var.app_name
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Package the Lambda handler from the repository root.
# This keeps the Terraform self-contained and avoids external build scripts.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../handler.py"
  output_path = "${path.module}/build/handler.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "venmo" {
  function_name = "${var.app_name}-handler"
  description   = "Automates Venmo payments/requests on a schedule"

  role    = aws_iam_role.lambda_role.arn
  handler = "handler.handler"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size
  publish     = false

  environment {
    variables = {
      VENMO_AUTH_TOKEN = var.venmo_auth_token
    }
  }

  tags = local.common_tags

  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}

# Optional SNS topic + email subscription for alarms
resource "aws_sns_topic" "alarms" {
  count = var.alarm_email == null ? 0 : 1

  name = "${var.app_name}-alarms"
  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "alarm_email" {
  count = var.alarm_email == null ? 0 : 1

  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  count = var.alarm_email == null ? 0 : 1

  alarm_name          = "${var.app_name}-lambda-errors"
  alarm_description   = "Alarm when the Venmo automation Lambda reports errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.venmo.function_name
  }

  alarm_actions = [aws_sns_topic.alarms[0].arn]
  ok_actions    = [aws_sns_topic.alarms[0].arn]

  tags = local.common_tags
}

# EventBridge schedules (one per recurring Venmo action)
resource "aws_cloudwatch_event_rule" "schedule" {
  for_each = { for s in var.venmo_schedules : s.name => s }

  name                = "${var.app_name}-${each.key}"
  description         = try(each.value.description, null)
  schedule_expression = each.value.cron_expression

  tags = local.common_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  for_each = aws_cloudwatch_event_rule.schedule

  rule      = each.value.name
  target_id = "invoke-lambda"
  arn       = aws_lambda_function.venmo.arn
  input     = var.venmo_schedules[index([for s in var.venmo_schedules : s.name], each.key)].payload
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = aws_cloudwatch_event_rule.schedule

  statement_id  = "AllowExecutionFromEventBridge-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.venmo.function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.arn
}
