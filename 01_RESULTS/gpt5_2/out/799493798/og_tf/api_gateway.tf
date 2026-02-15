resource "aws_api_gateway_rest_api" "gateway_to_lambda" {
  description = "For AWS Lambda"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  name = "s3-bucket-listing"
}

resource "aws_api_gateway_resource" "toplevel" {
  parent_id   = aws_api_gateway_rest_api.gateway_to_lambda.root_resource_id
  path_part   = "list-bucket-content"
  rest_api_id = aws_api_gateway_rest_api.gateway_to_lambda.id
}

resource "aws_api_gateway_resource" "folder" {
  parent_id   = aws_api_gateway_resource.toplevel.id
  path_part   = "{folder+}"
  rest_api_id = aws_api_gateway_rest_api.gateway_to_lambda.id
}

resource "aws_api_gateway_method" "toplevel" {
  api_key_required = "false"
  authorization    = "NONE"
  http_method      = "GET"
  resource_id      = aws_api_gateway_resource.toplevel.id
  rest_api_id      = aws_api_gateway_rest_api.gateway_to_lambda.id
}

resource "aws_api_gateway_method" "folder" {
  api_key_required = "false"
  authorization    = "NONE"
  http_method      = "GET"

  request_parameters = {
    "method.request.path.folder" = "true"
  }

  resource_id = aws_api_gateway_resource.folder.id
  rest_api_id = aws_api_gateway_rest_api.gateway_to_lambda.id
}

resource "aws_api_gateway_integration" "toplevel" {
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = "GET"
  integration_http_method = "POST" # lambda only accepts this
  resource_id             = aws_api_gateway_resource.toplevel.id
  rest_api_id             = aws_api_gateway_rest_api.gateway_to_lambda.id
  type                    = "AWS_PROXY" # for lambda proxy integration
  uri                     = aws_lambda_function.bucket_listing.invoke_arn
}

resource "aws_api_gateway_integration" "folder" {
  connection_type         = "INTERNET"
  content_handling        = "CONVERT_TO_TEXT"
  http_method             = "GET"
  integration_http_method = "POST"

  request_parameters = {
    "integration.request.path.folder" = "method.request.path.folder"
  }

  resource_id = aws_api_gateway_resource.folder.id
  rest_api_id = aws_api_gateway_rest_api.gateway_to_lambda.id
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.bucket_listing.invoke_arn
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.gateway_to_lambda.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.gateway_to_lambda.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.folder, aws_api_gateway_integration.folder]
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  description   = "v1 ; AWS Lambda"
  rest_api_id   = aws_api_gateway_rest_api.gateway_to_lambda.id
  stage_name    = "v1"
}
