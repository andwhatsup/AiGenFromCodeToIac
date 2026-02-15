output "api_invoke_url" {
  description = "Base invoke URL for the REST API stage."
  value       = aws_api_gateway_stage.prod.invoke_url
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.urldb.name
}

output "static_bucket_name" {
  value = aws_s3_bucket.static_site.bucket
}

output "static_website_endpoint" {
  description = "S3 website endpoint (note: bucket is not public by default)."
  value       = aws_s3_bucket_website_configuration.static_site.website_endpoint
}
