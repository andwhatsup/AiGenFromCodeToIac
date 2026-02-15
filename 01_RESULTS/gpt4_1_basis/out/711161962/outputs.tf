output "s3_bucket_name" {
  value = aws_s3_bucket.app_bucket.id
}

output "sqs_queue_url" {
  value = aws_sqs_queue.app_queue.id
}

output "lambda_function_name" {
  value = aws_lambda_function.app_lambda.function_name
}
