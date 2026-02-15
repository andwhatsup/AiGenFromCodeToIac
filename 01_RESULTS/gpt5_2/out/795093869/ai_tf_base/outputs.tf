output "input_bucket_id" {
  description = "S3 bucket name for uploading input.json"
  value       = aws_s3_bucket.input.id
}

output "lambda_function_name" {
  description = "Lambda function name that receives S3 events"
  value       = aws_lambda_function.trigger.function_name
}

output "aws_region" {
  value = var.aws_region
}
