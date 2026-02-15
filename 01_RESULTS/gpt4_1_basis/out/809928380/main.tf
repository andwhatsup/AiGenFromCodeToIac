data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.function_name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags = {
    Project = var.function_name
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "reminder_bot" {
  function_name    = var.function_name
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler.Handler::handleRequest"
  runtime          = var.lambda_runtime
  filename         = local.lambda_dummy_zip
  source_code_hash = data.archive_file.lambda_dummy.output_base64sha256
  environment {
    variables = {
      bot_token          = "<your_bot_token>"
      chat_id            = "<your_chat_id>"
      half_month_message = "<your_half_month_message>"
      end_month_message  = "<your_end_month_message>"
    }
  }
  tags = {
    Project = var.function_name
  }
}
