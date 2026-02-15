output "s3_bucket_name" {
  description = "S3 bucket used as the landing zone for the ETL pipeline."
  value       = aws_s3_bucket.data.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket."
  value       = aws_s3_bucket.data.arn
}

output "writer_role_arn" {
  description = "IAM role ARN that can be assumed by Lambda (stub) to write to the bucket."
  value       = aws_iam_role.writer.arn
}
