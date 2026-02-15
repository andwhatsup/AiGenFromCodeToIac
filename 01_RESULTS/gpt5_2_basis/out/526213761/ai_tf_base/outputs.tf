output "artifact_bucket_name" {
  description = "S3 bucket that can be used for Flink artifacts/checkpoints (and Kafka Connect S3 sink if used)."
  value       = aws_s3_bucket.artifacts.bucket
}

output "aws_region" {
  value = var.aws_region
}
