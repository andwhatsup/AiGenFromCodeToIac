output "artifact_bucket_name" {
  description = "S3 bucket name for storing artifacts/config (e.g., authmap)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "S3 bucket ARN."
  value       = aws_s3_bucket.artifacts.arn
}

output "read_artifacts_policy_arn" {
  description = "IAM policy ARN granting read-only access to the artifacts bucket."
  value       = aws_iam_policy.read_artifacts_bucket.arn
}
