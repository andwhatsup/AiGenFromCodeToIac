output "s3_bucket_name" {
  description = "S3 bucket to upload CSV files to."
  value       = aws_s3_bucket.uploads.bucket
}

output "sqs_queue_url" {
  description = "SQS queue URL receiving S3 notifications."
  value       = aws_sqs_queue.events.id
}

output "lambda_function_name" {
  description = "Lambda function name processing SQS messages."
  value       = aws_lambda_function.handler.function_name
}
