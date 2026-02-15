output "artifact_bucket_name" {
  description = "Name of the S3 bucket for artifacts"
  value       = aws_s3_bucket.artifact.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the S3 bucket for artifacts"
  value       = aws_s3_bucket.artifact.arn
}

output "basic_iam_role_arn" {
  description = "ARN of the basic IAM role"
  value       = aws_iam_role.basic.arn
}
