output "artifact_bucket_name" {
  description = "S3 bucket for storing artifacts related to this repository (e.g., packaged plugin, rendered templates)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}

output "iam_role_arn" {
  description = "Minimal IAM role stub that can be extended for CI/CD or deployment automation."
  value       = aws_iam_role.plugin_role.arn
}
