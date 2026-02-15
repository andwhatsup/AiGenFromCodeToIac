locals {
  name_prefix = var.app_name

  # If bucket_name is not provided, create a deterministic-ish name.
  # Note: S3 bucket names must be globally unique; override var.bucket_name if needed.
  effective_bucket_name = coalesce(var.bucket_name, lower(replace("${var.app_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}", "_", "-")))

  common_tags = {
    Application = var.app_name
    ManagedBy   = "terraform"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_s3_bucket" "app" {
  bucket = local.effective_bucket_name

  tags = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "lambda" {
  name = "${local.name_prefix}-lambda-role"

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

resource "aws_iam_role_policy" "lambda" {
  name = "${local.name_prefix}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Allow Lambda to write logs
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      # Allow listing objects in the bucket
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.app.arn
      },
      # Allow reading object metadata if needed (safe minimal read)
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.app.arn}/*"
      }
    ]
  })
}

resource "aws_lambda_function" "app" {
  function_name = "${local.name_prefix}-list-bucket-content"
  role          = aws_iam_role.lambda.arn

  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.app.bucket
    }
  }

  tags = local.common_tags

  depends_on = [aws_iam_role_policy.lambda]
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.app.function_name}"
  retention_in_days = 7

  tags = local.common_tags
}

# HTTP API (API Gateway v2) with Lambda proxy integration
resource "aws_apigatewayv2_api" "http" {
  name          = "${local.name_prefix}-http-api"
  protocol_type = "HTTP"

  tags = local.common_tags
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id = aws_apigatewayv2_api.http.id

  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.app.arn
  integration_method = "POST"

  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "root" {
  api_id = aws_apigatewayv2_api.http.id

  route_key = "GET /list-bucket-content"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_route" "folder" {
  api_id = aws_apigatewayv2_api.http.id

  # Greedy path parameter for folder
  route_key = "GET /list-bucket-content/{folder+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.http.id
  name   = var.stage_name

  auto_deploy = true

  tags = local.common_tags
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowExecutionFromAPIGatewayV2"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.http.execution_arn}/*/*"
}
