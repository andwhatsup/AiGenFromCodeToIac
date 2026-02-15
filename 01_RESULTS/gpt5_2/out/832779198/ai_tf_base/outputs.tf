output "aws_account_id" {
  description = "AWS account id used for deployment."
  value       = data.aws_caller_identity.current.account_id
}

output "bucket_name" {
  description = "S3 bucket name used for source/destination folders."
  value       = aws_s3_bucket.app.bucket
}

output "lambda_function_name" {
  description = "Lambda function name that moves objects from source/ to destination/."
  value       = aws_lambda_function.mover.function_name
}
