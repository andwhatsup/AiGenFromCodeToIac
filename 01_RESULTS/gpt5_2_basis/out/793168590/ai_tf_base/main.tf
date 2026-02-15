data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  lambda_zip_path = "${path.module}/build/lambda_function.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}-${var.lambda_function_name}-role"

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
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "invoke_sagemaker" {
  name        = "${var.app_name}-${var.lambda_function_name}-invoke-sagemaker"
  description = "Allow Lambda to invoke a specific SageMaker endpoint."

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
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.invoke_sagemaker.arn
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = replace("${var.app_name}-artifacts-", "_", "-")

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "lambda_source_snapshot" {
  bucket = aws_s3_bucket.artifacts.id
  key    = "lambda/src/lambda_function.py"
  source = "${path.module}/${var.lambda_source_dir}/lambda_function.py"
  etag   = filemd5("${path.module}/${var.lambda_source_dir}/lambda_function.py")
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/${var.lambda_source_dir}"
  output_path = local.lambda_zip_path
}

resource "aws_lambda_function" "invoker" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 30
  memory_size = 128

  environment {
    variables = {
      SAGEMAKER_ENDPOINT_NAME = var.sagemaker_endpoint_name
      AWS_REGION              = var.aws_region
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.app_name}-invoke-sagemaker-schedule"
  description         = "Scheduled trigger for Lambda to invoke SageMaker endpoint."
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.invoker.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.invoker.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
