locals {
  lambda_src_dir = "${path.module}/lambda_src"
}

# Package the repository's lambda.py as a Lambda deployment zip.
# Note: This repo imports aws_lambda_powertools; for a real deployment you would
# vendor dependencies into the zip or use a Lambda layer/container image.
# For Terraform validation purposes, packaging the handler file is sufficient.

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${local.lambda_src_dir}/lambda.py"
  output_path = "${path.module}/build/lambda.zip"
}

resource "aws_dynamodb_table" "urldb" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "short_url_id"

  attribute {
    name = "short_url_id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
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

resource "aws_iam_policy" "dynamodb_access" {
  name        = "${var.app_name}-dynamodb-access"
  description = "Allow Lambda to read/write URL records in DynamoDB."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.urldb.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

resource "aws_lambda_function" "app" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "lambda.handler"
  runtime = var.lambda_runtime

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size
  publish     = true

  environment {
    variables = {
      DYNAMODB_TABLE = var.dynamodb_table_name
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_dynamodb
  ]
}

resource "aws_apigatewayv2_api" "http_api" {
  name          = "${var.app_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.app.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "store" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /store"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

# Catch-all route for redirects: GET /{proxy+}
resource "aws_apigatewayv2_route" "proxy_get" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}
