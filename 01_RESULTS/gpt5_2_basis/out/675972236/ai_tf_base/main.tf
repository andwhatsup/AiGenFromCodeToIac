data "aws_caller_identity" "current" {}

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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Minimal Lambda for this repo: Rust lambda_runtime + function URL.
# Note: Terraform expects a deployment package at var.lambda_package_path.
resource "aws_lambda_function" "app" {
  function_name = var.app_name
  role          = aws_iam_role.lambda_exec.arn

  runtime       = var.lambda_runtime
  handler       = var.lambda_handler
  architectures = var.lambda_architectures

  # Use a generated dummy zip during evaluation if the user hasn't provided one.
  # This avoids plan-time failures from filebase64sha256() when the file is missing.
  filename         = fileexists(var.lambda_package_path) ? var.lambda_package_path : data.archive_file.lambda_dummy.output_path
  source_code_hash = filebase64sha256(fileexists(var.lambda_package_path) ? var.lambda_package_path : data.archive_file.lambda_dummy.output_path)

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      RUST_LOG = "info"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}

resource "aws_lambda_function_url" "app" {
  function_name      = aws_lambda_function.app.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_permission" "allow_function_url" {
  statement_id           = "AllowFunctionUrlInvoke"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.app.function_name
  principal              = "*"
  function_url_auth_type = "NONE"
}
