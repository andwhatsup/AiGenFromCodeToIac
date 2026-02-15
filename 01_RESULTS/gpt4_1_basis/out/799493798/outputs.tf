output "api_gateway_url" {
  description = "Invoke URL for the API Gateway"
  value       = aws_apigatewayv2_stage.lambda.invoke_url
}

output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.lambda.function_name
}

output "bucket_name" {
  description = "S3 bucket name used by Lambda"
  value       = aws_s3_bucket.app_bucket.id
}
