output "lambda_function_name" {
  description = "Deployed Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "dynamodb_lock_table_name" {
  description = "DynamoDB table used for locking"
  value       = aws_dynamodb_table.lock.name
}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  value = data.aws_region.current.region
}
