output "lambda_function_name" {
  value = aws_lambda_function.venmo_action.function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.venmo_action.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.venmo_action.invoke_arn
}
