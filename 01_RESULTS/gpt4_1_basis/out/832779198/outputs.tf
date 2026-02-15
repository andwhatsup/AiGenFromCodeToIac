output "lambda_function_name" {
  description = "Name of the Lambda function deployed"
  value       = aws_lambda_function.app_lambda.function_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Lambda events"
  value       = aws_s3_bucket.lambda_events.bucket
}
