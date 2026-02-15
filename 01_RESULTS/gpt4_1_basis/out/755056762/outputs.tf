output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for ETL data."
  value       = aws_s3_bucket.etl_data.arn
}

