resource "aws_iam_role" "lambda_exec" {
  name               = "${var.app_name}-lambda-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "check_announcement" {
  function_name    = "${var.app_name}-check-announcement"
  handler          = "main"
  runtime          = "go1.x"
  role             = aws_iam_role.lambda_exec.arn
  filename         = local.lambda_dummy_zip
  source_code_hash = "dummyhash-check_announcement"
  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.announcements.name
      BASE_URL       = var.base_url
      DATE_FORMAT    = var.date_format
    }
  }
}

resource "aws_lambda_function" "send_notification" {
  function_name    = "${var.app_name}-send-notification"
  handler          = "main"
  runtime          = "go1.x"
  role             = aws_iam_role.lambda_exec.arn
  filename         = local.lambda_dummy_zip
  source_code_hash = "dummyhash-send_notification"
  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.announcements.arn
    }
  }
}

resource "aws_lambda_function" "send_telegram_notification" {
  function_name    = "${var.app_name}-send-telegram-notification"
  handler          = "main"
  runtime          = "go1.x"
  role             = aws_iam_role.lambda_exec.arn
  filename         = local.lambda_dummy_zip
  source_code_hash = "dummyhash-send_telegram_notification"
  environment {
    variables = {
      SSM_TELEGRAM_AUTH_TOKEN = aws_ssm_parameter.telegram_auth_token.name
    }
  }
}
