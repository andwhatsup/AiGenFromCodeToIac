output "aws_region" {
  description = "AWS region in use."
  value       = var.aws_region
}

output "state_bucket_name" {
  description = "Name of the S3 bucket created for Terraform state (if enabled)."
  value       = var.create_state_bucket ? aws_s3_bucket.tf_state[0].bucket : null
}

output "lock_table_name" {
  description = "Name of the DynamoDB table created for Terraform state locking (if enabled)."
  value       = var.create_lock_table ? aws_dynamodb_table.tf_locks[0].name : null
}
