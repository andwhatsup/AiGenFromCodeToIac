data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "../"
  output_path = "./handler.zip"
  excludes    = ["ai_basis_tf", ".git", "*.md", "*.sh", "*.gitignore", "LICENSE"]
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.lambda_function_name}-exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = {
    Name = var.lambda_function_name
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "venmo_action" {
  function_name    = var.lambda_function_name
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  role             = aws_iam_role.lambda_exec.arn
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      VENMO_AUTH_TOKEN = var.venmo_auth_token
    }
  }
  tags = {
    Name = var.lambda_function_name
  }
}

resource "aws_cloudwatch_event_rule" "venmo_schedule" {
  count               = length(local.venmo_schedules)
  name                = local.venmo_schedules[count.index]["name"]
  description         = local.venmo_schedules[count.index]["description"]
  schedule_expression = local.venmo_schedules[count.index]["cron_expression"]
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  count = length(local.venmo_schedules)
  rule  = aws_cloudwatch_event_rule.venmo_schedule[count.index].name
  arn   = aws_lambda_function.venmo_action.arn
  input = local.venmo_schedules[count.index]["payload"]
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  count         = length(local.venmo_schedules)
  statement_id  = "AllowExecutionFromCloudWatch${count.index}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.venmo_action.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.venmo_schedule[count.index].arn
}

locals {
  venmo_schedules = [] # User must fill this in with their schedule objects
}
