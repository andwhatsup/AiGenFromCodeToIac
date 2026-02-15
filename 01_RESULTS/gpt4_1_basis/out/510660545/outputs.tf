output "example_s3_bucket_name" {
  description = "Name of the example S3 bucket created."
  value       = aws_s3_bucket.artifacts_bucket.id
}
