output "aws_account_id" {
  description = "AWS account id where this Terraform is applied"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region where this Terraform is applied"
  value       = data.aws_region.current.name
}

output "artifact_bucket_name" {
  description = "S3 bucket for artifacts/configs"
  value       = aws_s3_bucket.artifacts.bucket
}

output "pod_identity_source_role_arn" {
  description = "IAM role ARN intended to be used as the EKS Pod Identity source role"
  value       = aws_iam_role.pod_identity_source.arn
}
