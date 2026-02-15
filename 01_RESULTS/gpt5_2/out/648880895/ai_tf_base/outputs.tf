output "s3_bucket_name" {
  description = "S3 bucket name to use in the boto3 workshop scripts."
  value       = aws_s3_bucket.workshop.bucket
}

output "sample_object_key" {
  description = "Example object key created in the bucket."
  value       = aws_s3_object.sample_image.key
}
