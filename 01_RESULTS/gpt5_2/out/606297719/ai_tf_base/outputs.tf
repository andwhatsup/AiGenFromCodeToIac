output "aws_account_id" {
  description = "AWS account id."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region in use."
  value       = data.aws_region.current.id
}

output "prefect_artifacts_bucket_name" {
  description = "S3 bucket for Prefect flow storage/artifacts."
  value       = aws_s3_bucket.prefect_artifacts.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL for a custom Prefect agent image (if created)."
  value       = var.create_ecr_repository ? aws_ecr_repository.agent[0].repository_url : null
}
