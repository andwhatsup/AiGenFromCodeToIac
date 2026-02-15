data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_ecr_repository" "playwright_lambda" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

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

# Lambda container image function.
# Note: the image must be pushed to ECR separately (see Makefile in repo).
resource "aws_lambda_function" "playwright" {
  function_name = var.app_name
  role          = aws_iam_role.lambda_exec.arn
  package_type  = "Image"

  image_uri = "${aws_ecr_repository.playwright_lambda.repository_url}:${var.lambda_image_tag}"

  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  architectures = ["x86_64"]

  environment {
    variables = {
      NODE_OPTIONS = "--enable-source-maps"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}

# Optional: allow invoking the function from your AWS account (useful for manual tests).
resource "aws_lambda_permission" "allow_account_invoke" {
  statement_id  = "AllowAccountInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.playwright.function_name
  principal     = data.aws_caller_identity.current.account_id
}
