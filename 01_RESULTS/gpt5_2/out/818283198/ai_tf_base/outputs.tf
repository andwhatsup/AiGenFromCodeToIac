output "aws_account_id" {
  description = "AWS account id used for deployment."
  value       = data.aws_caller_identity.current.account_id
}

output "ecr_repository_url" {
  description = "ECR repository URL to push the Lambda image to."
  value       = aws_ecr_repository.this.repository_url
}

output "lambda_function_name" {
  description = "Deployed Lambda function name."
  value       = aws_lambda_function.this.function_name
}

output "lambda_image_uri" {
  description = "Image URI configured on the Lambda function."
  value       = aws_lambda_function.this.image_uri
}
