output "bucket_name" {
  description = "S3 bucket used by the Lambda function"
  value       = aws_s3_bucket.app.bucket
}

output "api_base_url" {
  description = "Base URL for the HTTP API stage"
  value       = aws_apigatewayv2_stage.v1.invoke_url
}

output "api_route" {
  description = "Convenience URL for the list-bucket-content route"
  value       = "${aws_apigatewayv2_stage.v1.invoke_url}/list-bucket-content"
}
