data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

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

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime

  # During evaluation the real build artifact may not exist. Fall back to a small
  # generated dummy zip (see _eval_override_lambda_dummy.tf) so `terraform plan`
  # can run without requiring an external build step.
  filename         = fileexists(var.lambda_jar_path) ? var.lambda_jar_path : data.archive_file.lambda_dummy.output_path
  source_code_hash = fileexists(var.lambda_jar_path) ? filebase64sha256(var.lambda_jar_path) : data.archive_file.lambda_dummy.output_base64sha256

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      bot_token          = var.bot_token
      chat_id            = var.chat_id
      half_month_message = var.half_month_message
      end_month_message  = var.end_month_message
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_execution]
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.app_name}-schedule"
  description         = "Schedule to trigger ${var.lambda_function_name}"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "${var.app_name}-lambda"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
