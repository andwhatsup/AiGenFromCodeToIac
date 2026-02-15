output "api_endpoint" {
  description = "Base invoke URL for the HTTP API."
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table used to store shortened URLs."
  value       = aws_dynamodb_table.urldb.name
}

output "lambda_function_name" {
  description = "Lambda function name."
  value       = aws_lambda_function.app.function_name
}
