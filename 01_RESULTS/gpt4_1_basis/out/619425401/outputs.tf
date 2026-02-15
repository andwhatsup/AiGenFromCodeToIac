output "lambda_function_name" {
  value = aws_lambda_function.delta_optimize_lambda.function_name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.lock_table.name
}
