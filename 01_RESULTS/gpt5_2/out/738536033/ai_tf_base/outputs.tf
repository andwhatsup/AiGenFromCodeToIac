output "artifact_bucket_name" {
  description = "S3 bucket for application artifacts (e.g., Elastic Beanstalk application versions)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "app_iam_role_arn" {
  description = "IAM role ARN that can be used by compute (e.g., EC2/Elastic Beanstalk instances) to access the artifact bucket."
  value       = aws_iam_role.app_role.arn
}
