output "input_bucket_id" {
  description = "S3 bucket for input files"
  value       = aws_s3_bucket.input.id
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.trigger.function_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name (optional idempotency/retry store)"
  value       = aws_dynamodb_table.events.name
}
