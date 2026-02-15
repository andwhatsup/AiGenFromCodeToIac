output "s3_bucket_name" {
  description = "S3 bucket that triggers the Lambda and stores source/destination objects."
  value       = aws_s3_bucket.app.bucket
}

output "lambda_function_name" {
  description = "Lambda function that moves objects from source/ to destination/."
  value       = aws_lambda_function.mover.function_name
}
