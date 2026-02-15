resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}-lambda-exec"
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
    App = var.app_name
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "product_lambda" {
  function_name    = "${var.app_name}-lambda"
  handler          = "example.Handler::handleRequest"
  runtime          = "java11"
  role             = aws_iam_role.lambda_exec.arn
  filename         = "../product-lambda.jar"
  source_code_hash = filebase64sha256("../product-lambda.jar")
  timeout          = 10
  memory_size      = 512
  tags = {
    App = var.app_name
  }
}

resource "aws_api_gateway_rest_api" "product_api" {
  name        = "${var.app_name}-api"
  description = "API Gateway for Product Lambda"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    App = var.app_name
  }
}

resource "aws_api_gateway_resource" "product" {
  rest_api_id = aws_api_gateway_rest_api.product_api.id
  parent_id   = aws_api_gateway_rest_api.product_api.root_resource_id
  path_part   = "productApi"
}

resource "aws_api_gateway_method" "product_post" {
  rest_api_id   = aws_api_gateway_rest_api.product_api.id
  resource_id   = aws_api_gateway_resource.product.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "product_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.product_api.id
  resource_id             = aws_api_gateway_resource.product.id
  http_method             = aws_api_gateway_method.product_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.product_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.product_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.product_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "product_api_deployment" {
  depends_on  = [aws_api_gateway_integration.product_post_integration]
  rest_api_id = aws_api_gateway_rest_api.product_api.id
}

resource "aws_api_gateway_stage" "dev" {
  stage_name    = "dev"
  rest_api_id   = aws_api_gateway_rest_api.product_api.id
  deployment_id = aws_api_gateway_deployment.product_api_deployment.id
}
