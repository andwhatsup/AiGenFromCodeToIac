output "backup_bucket_name" {
  description = "S3 bucket where SSM Parameter Store backups are stored."
  value       = aws_s3_bucket.backup.bucket
}

output "kms_key_arn" {
  description = "KMS key ARN used for S3 server-side encryption."
  value       = aws_kms_key.backup.arn
}

output "lambda_function_name" {
  description = "Lambda function name that performs the backup."
  value       = aws_lambda_function.backup.function_name
}

output "event_rule_name" {
  description = "EventBridge rule name that triggers the backup."
  value       = aws_cloudwatch_event_rule.schedule.name
}
