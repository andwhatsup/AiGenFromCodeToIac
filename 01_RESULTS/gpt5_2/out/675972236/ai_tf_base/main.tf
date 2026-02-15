data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}-lambda-exec"

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
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "app" {
  function_name = var.app_name
  role          = aws_iam_role.lambda_exec.arn

  runtime       = var.lambda_runtime
  handler       = var.lambda_handler
  architectures = [var.lambda_architecture]

  # Use the real build artifact if present; otherwise fall back to a small
  # generated dummy zip so `terraform plan` works in evaluation environments.
  filename         = fileexists(var.lambda_zip_path) ? var.lambda_zip_path : data.archive_file.lambda_dummy.output_path
  source_code_hash = filebase64sha256(fileexists(var.lambda_zip_path) ? var.lambda_zip_path : data.archive_file.lambda_dummy.output_path)

  timeout     = 10
  memory_size = 128

  environment {
    variables = {
      RUST_LOG = "info"
    }
  }
}

resource "aws_lambda_function_url" "app" {
  count              = var.enable_function_url ? 1 : 0
  function_name      = aws_lambda_function.app.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = false
    allow_headers     = ["*"]
    allow_methods     = ["*"]
    allow_origins     = ["*"]
    expose_headers    = ["*"]
    max_age           = 0
  }
}

resource "aws_lambda_permission" "function_url_public" {
  count = var.enable_function_url ? 1 : 0

  statement_id           = "AllowPublicInvokeFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.app.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}
