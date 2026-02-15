output "artifact_bucket_name" {
  description = "S3 bucket for storing cluster artifacts."
  value       = aws_s3_bucket.artifacts.bucket
}

output "automation_role_arn" {
  description = "IAM role ARN intended for future automation (e.g., EC2-based provisioning)."
  value       = aws_iam_role.automation.arn
}
