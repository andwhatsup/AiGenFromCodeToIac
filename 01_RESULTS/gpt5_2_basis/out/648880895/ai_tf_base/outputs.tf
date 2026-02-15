output "bucket_name" {
  description = "Name of the S3 bucket used by the workshop scripts."
  value       = aws_s3_bucket.workshop.bucket
}

output "sample_object_key" {
  description = "Key of the uploaded sample object."
  value       = aws_s3_object.sample_image.key
}
