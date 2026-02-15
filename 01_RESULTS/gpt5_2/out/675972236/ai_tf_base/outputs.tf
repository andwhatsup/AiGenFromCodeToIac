output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.app.function_name
}

output "lambda_function_arn" {
  description = "Deployed Lambda function ARN"
  value       = aws_lambda_function.app.arn
}

output "lambda_function_url" {
  description = "Public Lambda Function URL (if enabled)"
  value       = try(aws_lambda_function_url.app[0].function_url, null)
}
