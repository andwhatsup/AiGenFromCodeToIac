output "artifact_bucket_name" {
  description = "Name of the S3 bucket for storing artifacts."
  value       = aws_s3_bucket.artifact_bucket.id
}
