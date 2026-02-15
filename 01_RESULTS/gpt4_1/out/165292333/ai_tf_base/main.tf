resource "aws_dynamodb_table" "url_table" {
  name         = "URLDB"
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

  tags = {
    Name = "${var.app_name}-dynamodb"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}_lambda_exec_role"
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
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.app_name}_lambda_policy"
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = aws_dynamodb_table.url_table.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_lambda_function" "url_shortener" {
  function_name    = "${var.app_name}_lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda.handler"
  runtime          = "python3.9"
  filename         = "dummy_lambda.zip" # Placeholder for validation
  source_code_hash = "dummyhash"        # Placeholder for validation
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.url_table.name
    }
  }
  tags = {
    Name = "${var.app_name}-lambda"
  }
}

resource "aws_apigatewayv2_api" "url_api" {
  name          = "${var.app_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id                 = aws_apigatewayv2_api.url_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.url_shortener.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "store_route" {
  api_id    = aws_apigatewayv2_api.url_api.id
  route_key = "POST /store"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "redirect_route" {
  api_id    = aws_apigatewayv2_api.url_api.id
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.url_api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url_shortener.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.url_api.execution_arn}/*/*"
}
