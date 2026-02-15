output "rest_api_id" {
  description = "API Gateway REST API ID."
  value       = aws_api_gateway_rest_api.this.id
}

output "invoke_url" {
  description = "Base invoke URL for the deployed stage."
  value       = aws_api_gateway_stage.this.invoke_url
}

output "lambda_function_name" {
  description = "Deployed Lambda function name."
  value       = aws_lambda_function.product.function_name
}
