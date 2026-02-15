output "lambda_function_name" {
  value = aws_lambda_function.url_shortener.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.url_table.name
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.url_api.api_endpoint
}
