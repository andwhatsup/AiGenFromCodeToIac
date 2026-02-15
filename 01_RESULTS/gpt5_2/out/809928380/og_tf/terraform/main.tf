resource "aws_iam_role" "lambda_execution_role" {
  name = "reminder-bot-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "reminder-bot-lambda-policy"
  description = "Policy for reminder bot lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = aws_lambda_function.reminder_bot_lambda.arn
      }
    ]
  })
}

resource "aws_lambda_function" "reminder_bot_lambda" {
  function_name = "reminder-bot-lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  filename      = "${path.module}/dummy.jar"
  handler       = "handler.Handler"
  runtime       = "java21"
  timeout       = 60

  lifecycle {
    ignore_changes = [filename]
  }

  environment {
    variables = {
      bot_token          = var.bot_token,
      chat_id            = var.chat_id,
      half_month_message = var.half_month_message,
      end_month_message  = var.end_month_message
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_cloudwatch_event_rule" "reminder_bot_schedule" {
  name                = "reminder-bot-schedule"
  description         = "Schedule rule for reminder bot Lambda function"
  schedule_expression = "cron(30 20 15,28 * ? *)"
}

resource "aws_cloudwatch_event_target" "reminder_bot_target" {
  rule      = aws_cloudwatch_event_rule.reminder_bot_schedule.name
  target_id = "reminder-bot-lambda-target"
  arn       = aws_lambda_function.reminder_bot_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reminder_bot_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.reminder_bot_schedule.arn
}