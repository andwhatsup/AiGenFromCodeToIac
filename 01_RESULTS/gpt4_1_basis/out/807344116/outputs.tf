output "artifact_bucket_name" {
  description = "Name of the S3 bucket for artifacts."
  value       = aws_s3_bucket.artifacts.id
}
