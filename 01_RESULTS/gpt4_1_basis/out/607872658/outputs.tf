output "s3_bucket_name" {
  description = "Name of the S3 bucket for SSM backups"
  value       = aws_s3_bucket.ssm_backup.bucket
}

output "lambda_function_name" {
  description = "Name of the Lambda function performing the backup"
  value       = aws_lambda_function.ssm_backup.function_name
}

output "cloudwatch_event_rule_arn" {
  description = "ARN of the CloudWatch Event Rule triggering the Lambda"
  value       = aws_cloudwatch_event_rule.daily.arn
}
