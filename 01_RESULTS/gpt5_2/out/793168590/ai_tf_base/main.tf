data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# Package the repository's lambda function (invokes a SageMaker endpoint)
# Source: ../lambda/src/lambda_function.py

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/src"
  output_path = "${path.module}/build/lambda_function.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Allow invoking the specified SageMaker endpoint
resource "aws_iam_policy" "invoke_sagemaker" {
  name        = "${var.app_name}-invoke-sagemaker"
  description = "Allow Lambda to invoke a SageMaker endpoint"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sagemaker:InvokeEndpoint"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:sagemaker:${var.aws_region}:${data.aws_caller_identity.current.account_id}:endpoint/${var.sagemaker_endpoint_name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "invoke_sagemaker" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.invoke_sagemaker.arn
}

resource "aws_lambda_function" "invoke_endpoint" {
  function_name = "${var.app_name}-invoke-endpoint"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 30

  environment {
    variables = {
      SAGEMAKER_ENDPOINT_NAME = var.sagemaker_endpoint_name
      AWS_REGION              = var.aws_region
    }
  }
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.app_name}-schedule"
  description         = "Schedule Lambda to invoke SageMaker endpoint"
  schedule_expression = var.lambda_schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "invoke-endpoint"
  arn       = aws_lambda_function.invoke_endpoint.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invoke_endpoint.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}

# Minimal artifact bucket (useful for model artifacts or logs if needed)
resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${var.app_name}-artifacts-"
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
