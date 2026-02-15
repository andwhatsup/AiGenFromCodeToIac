output "s3_bucket_name" {
  description = "S3 bucket for storing artifacts/datasets/notebook exports."
  value       = aws_s3_bucket.artifacts.bucket
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.artifacts.arn
}
