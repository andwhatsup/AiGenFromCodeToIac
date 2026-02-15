output "aws_region" {
  value       = var.aws_region
  description = "AWS region in use."
}

output "artifacts_bucket_name" {
  value       = aws_s3_bucket.artifacts.bucket
  description = "S3 bucket for build artifacts / snapshots."
}

output "lambda_function_name" {
  value       = aws_lambda_function.invoker.function_name
  description = "Lambda function that invokes the SageMaker endpoint."
}

output "eventbridge_rule_name" {
  value       = aws_cloudwatch_event_rule.schedule.name
  description = "EventBridge schedule rule name."
}

output "sagemaker_endpoint_name" {
  value       = var.sagemaker_endpoint_name
  description = "SageMaker endpoint name that the Lambda is configured to invoke."
}
