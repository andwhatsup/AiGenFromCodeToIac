output "bucket_name" {
  description = "S3 bucket used by the Lambda function"
  value       = aws_s3_bucket.app.bucket
}

output "api_base_url" {
  description = "Base URL for the deployed HTTP API stage"
  value       = aws_apigatewayv2_stage.stage.invoke_url
}

output "api_route" {
  description = "Convenience URL for listing bucket content"
  value       = "${aws_apigatewayv2_stage.stage.invoke_url}/list-bucket-content"
}
