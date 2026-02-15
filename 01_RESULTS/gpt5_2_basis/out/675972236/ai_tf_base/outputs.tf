output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.app.function_name
}

output "lambda_function_arn" {
  description = "Deployed Lambda function ARN"
  value       = aws_lambda_function.app.arn
}

output "lambda_function_url" {
  description = "Public Lambda Function URL"
  value       = aws_lambda_function_url.app.function_url
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = data.aws_region.current.name
}
