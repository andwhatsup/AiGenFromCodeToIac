output "s3_bucket_name" {
  value = aws_s3_bucket.artifacts.bucket
}

output "iam_role_name" {
  value = aws_iam_role.basic.name
}
