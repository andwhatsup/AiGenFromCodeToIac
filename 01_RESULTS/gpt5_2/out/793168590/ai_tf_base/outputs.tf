output "lambda_function_name" {
  value       = aws_lambda_function.invoke_endpoint.function_name
  description = "Deployed Lambda function name"
}

output "event_rule_name" {
  value       = aws_cloudwatch_event_rule.schedule.name
  description = "EventBridge rule that triggers the Lambda"
}

output "artifacts_bucket_name" {
  value       = aws_s3_bucket.artifacts.bucket
  description = "S3 bucket for artifacts"
}
