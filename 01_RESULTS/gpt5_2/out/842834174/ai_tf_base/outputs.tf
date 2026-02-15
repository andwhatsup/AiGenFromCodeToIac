output "aws_account_id" {
  description = "AWS account id used by the provider."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used by the provider."
  value       = data.aws_region.current.id
}

output "artifacts_bucket_name" {
  description = "S3 bucket for storing build artifacts/static assets."
  value       = aws_s3_bucket.artifacts.bucket
}
