output "lambda_function_name" {
  value       = aws_lambda_function.this.function_name
  description = "Deployed Lambda function name"
}

output "dynamodb_lock_table_name" {
  value       = aws_dynamodb_table.lock.name
  description = "DynamoDB table used for S3 locking"
}

output "cloudwatch_event_rule_name" {
  value       = aws_cloudwatch_event_rule.schedule.name
  description = "CloudWatch Events rule that triggers the Lambda"
}
