output "demo_bucket_name" {
  description = "A demo S3 bucket created by Terraform."
  value       = aws_s3_bucket.demo.bucket
}

output "iam_user_name" {
  description = "IAM user that can list S3 buckets."
  value       = aws_iam_user.app.name
}

output "aws_access_key_id" {
  description = "Access key id for the IAM user (use with the secret access key output)."
  value       = aws_iam_access_key.app.id
}

output "aws_secret_access_key" {
  description = "Secret access key for the IAM user."
  value       = aws_iam_access_key.app.secret
  sensitive   = true
}
