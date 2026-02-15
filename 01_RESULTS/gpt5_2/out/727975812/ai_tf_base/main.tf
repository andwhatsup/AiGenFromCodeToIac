locals {
  lambda_name = "${var.app_name}-handler"
}

# Package lambda code from the repository root.
# This expects handler.py and requirements.txt to exist at the repo root.
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/handler.zip"

  source {
    content  = file("${path.module}/handler.py")
    filename = "handler.py"
  }

  # requirements.txt contains only "venmo-api" in this repo.
  # We do not vendor dependencies here to keep the Terraform minimal and validate-only.
  # For a real deployment, build a proper zip (or container image) including dependencies.
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
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.handler"
  runtime       = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      VENMO_AUTH_TOKEN = var.venmo_auth_token
    }
  }
}

# EventBridge Scheduler (new service) requires a role to invoke Lambda.
resource "aws_iam_role" "scheduler_role" {
  name = "${var.app_name}-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "scheduler_invoke_lambda" {
  name = "${var.app_name}-scheduler-invoke-lambda"
  role = aws_iam_role.scheduler_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = aws_lambda_function.this.arn
      }
    ]
  })
}

resource "aws_scheduler_schedule" "venmo" {
  for_each = { for s in var.venmo_schedules : s.name => s }

  name        = each.value.name
  description = try(each.value.description, "")

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = each.value.cron_expression

  target {
    arn      = aws_lambda_function.this.arn
    role_arn = aws_iam_role.scheduler_role.arn
    input    = each.value.payload
  }
}

# SNS topic + CloudWatch alarm for Lambda errors (optional email subscription)
resource "aws_sns_topic" "alarms" {
  name = "${var.app_name}-alarms"
}

resource "aws_sns_topic_subscription" "email" {
  count = var.alarm_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.app_name}-lambda-errors"
  alarm_description   = "Alarm when the Lambda function reports errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = aws_lambda_function.this.function_name
  }

  alarm_actions = [aws_sns_topic.alarms.arn]
}
