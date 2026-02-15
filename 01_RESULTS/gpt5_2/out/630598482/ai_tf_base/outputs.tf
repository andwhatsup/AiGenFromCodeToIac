output "artifact_bucket_name" {
  description = "S3 bucket for application build artifacts/static exports."
  value       = aws_s3_bucket.artifacts.bucket
}

output "cicd_role_arn" {
  description = "IAM role ARN (stub) that can be assumed by CI/CD to upload artifacts."
  value       = aws_iam_role.cicd.arn
}
