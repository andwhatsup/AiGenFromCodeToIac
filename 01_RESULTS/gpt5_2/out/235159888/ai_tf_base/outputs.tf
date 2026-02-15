output "artifact_bucket_name" {
  description = "Name of the S3 bucket created for artifacts/state-like storage."
  value       = aws_s3_bucket.artifacts.bucket
}

output "artifact_bucket_arn" {
  description = "ARN of the S3 bucket created for artifacts."
  value       = aws_s3_bucket.artifacts.arn
}

output "artifact_writer_role_arn" {
  description = "ARN of the IAM role that can read/write objects in the artifact bucket."
  value       = aws_iam_role.artifact_writer.arn
}
