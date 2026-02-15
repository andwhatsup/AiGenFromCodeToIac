output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "iam_group_name" {
  description = "The name of the IAM group"
  value       = aws_iam_group.this.name
}

output "iam_user_name" {
  description = "The name of the IAM user"
  value       = aws_iam_user.this.name
}

output "iam_role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.this.name
}
