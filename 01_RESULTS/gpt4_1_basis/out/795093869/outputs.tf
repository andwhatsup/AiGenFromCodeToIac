output "input_bucket_id" {
  description = "ID of the S3 bucket for input files."
  value       = aws_s3_bucket.input_bucket.id
}

output "mwaa_webserver_url" {
  description = "MWAA Webserver URL."
  value       = aws_mwaa_environment.mwaa.webserver_url
}
