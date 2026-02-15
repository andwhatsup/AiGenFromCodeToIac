locals {
  lambda_name = "${var.app_name}-handler"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# S3 bucket that receives CSV uploads
resource "aws_s3_bucket" "uploads" {
  bucket        = coalesce(var.bucket_name, "${var.app_name}-${random_id.suffix.hex}")
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SQS queue that receives S3 event notifications
resource "aws_sqs_queue" "events" {
  name = "${var.app_name}-events"
}

# Allow S3 to send messages to the SQS queue
resource "aws_sqs_queue_policy" "allow_s3" {
  queue_url = aws_sqs_queue.events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3SendMessage"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.events.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.uploads.arn
          }
        }
      }
    ]
  })
}

# S3 -> SQS notification
resource "aws_s3_bucket_notification" "to_sqs" {
  bucket = aws_s3_bucket.uploads.id

  queue {
    queue_arn     = aws_sqs_queue.events.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".csv"
  }

  depends_on = [aws_sqs_queue_policy.allow_s3]
}

# IAM role for Lambda
data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.app_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# Minimal permissions: write logs + read from SQS
data "aws_iam_policy_document" "lambda_inline" {
  statement {
    sid    = "AllowCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowSqsConsume"
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility"
    ]
    resources = [aws_sqs_queue.events.arn]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${var.app_name}-lambda-inline"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_inline.json
}

# Package the Go lambda binary (expects it to be built at ../lambda/build/bootstrap)
# This keeps Terraform minimal and compatible with LocalStack-style workflows.
# Build command example:
#   (cd lambda && GOOS=linux GOARCH=amd64 go build -o build/bootstrap handler.go)
#   (cd lambda && zip -j build/function.zip build/bootstrap)

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/build/bootstrap"
  output_path = "${path.module}/.terraform-build/${local.lambda_name}.zip"
}

resource "aws_lambda_function" "handler" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda.arn

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "bootstrap"
  runtime = "provided.al2"

  timeout     = 10
  memory_size = 128

  depends_on = [aws_iam_role_policy.lambda_inline]
}

# Event source mapping: SQS -> Lambda
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = aws_sqs_queue.events.arn
  function_name    = aws_lambda_function.handler.arn

  batch_size = 10
  enabled    = true
}
