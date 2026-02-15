output "lambda_function_name" {
  value = aws_lambda_function.this.function_name
}

output "lambda_function_url" {
  value = aws_lambda_function_url.this.function_url
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}
