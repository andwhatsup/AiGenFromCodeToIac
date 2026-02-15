data "archive_file" "zipped_code" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "bucket_listing" {
  description = "to list contents of S3 bucket like filesystem ls"

  environment {
    variables = {
      BUCKET_NAME = var.bucket_name
    }
  }

  function_name = "s3-bucket-listing"
  handler       = "lambda_function.lambda_handler"

  logging_config {
    log_format = "Text"
    log_group  = "/aws/lambda/s3-bucket-listing"
  }

  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.10"
  filename         = data.archive_file.zipped_code.output_path
  source_code_hash = data.archive_file.zipped_code.output_base64sha256

  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_lambda_permission" "toplevel" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bucket_listing.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway_to_lambda.execution_arn}/*/${aws_api_gateway_method.toplevel.http_method}${aws_api_gateway_resource.toplevel.path}"
}

resource "aws_lambda_permission" "folder" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bucket_listing.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.gateway_to_lambda.execution_arn}/*/${aws_api_gateway_method.folder.http_method}${aws_api_gateway_resource.folder.path}"
}

