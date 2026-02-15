output "ecr_repository_url" {
  description = "ECR repository URL to push the Lambda container image to."
  value       = aws_ecr_repository.lambda.repository_url
}

output "lambda_function_name" {
  description = "Deployed Lambda function name."
  value       = aws_lambda_function.this.function_name
}

output "eventbridge_rule_name" {
  description = "EventBridge rule that triggers the Lambda."
  value       = aws_cloudwatch_event_rule.schedule.name
}

output "cloudtrail_bucket_name" {
  description = "S3 bucket used for CloudTrail logs."
  value       = aws_s3_bucket.cloudtrail.id
}

output "cloudtrail_name" {
  description = "CloudTrail name."
  value       = aws_cloudtrail.this.name
}
