output "aws_account_id" {
  description = "AWS account ID used for deployment."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used for deployment."
  value       = data.aws_region.current.name
}

output "artifacts_bucket_name" {
  description = "S3 bucket for artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}

output "dynamodb_lock_table_name" {
  description = "DynamoDB table that can be used for Terraform state locking."
  value       = aws_dynamodb_table.tf_lock.name
}

output "iam_role_name" {
  description = "IAM role stub (assumable by EC2) for future expansion."
  value       = aws_iam_role.app.name
}
