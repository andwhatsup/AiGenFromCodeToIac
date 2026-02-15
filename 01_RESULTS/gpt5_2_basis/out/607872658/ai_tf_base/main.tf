locals {
  name_prefix = "${var.app_name}-${var.environment}"
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

# KMS key for encrypting S3 objects
resource "aws_kms_key" "backup" {
  description             = "KMS key for ${local.name_prefix} SSM Parameter Store backups"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "backup" {
  name          = "alias/${local.name_prefix}-backup"
  target_key_id = aws_kms_key.backup.key_id
}

# S3 bucket to store backups
# NOTE: aws_s3_bucket.bucket_prefix has a max length of 37 characters.
# Keep the prefix short and deterministic; AWS will append random characters.
resource "aws_s3_bucket" "backup" {
  bucket_prefix = "ssm-bkp-${var.environment}-"
  force_destroy = var.s3_force_destroy
}

resource "aws_s3_bucket_versioning" "backup" {
  bucket = aws_s3_bucket.backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  bucket = aws_s3_bucket.backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.backup.arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  bucket = aws_s3_bucket.backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Package the Lambda code from the repository
# NOTE: This expects the repo layout to include function/ssm_backup.py
# at the path relative to this Terraform working directory.

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../function/ssm_backup.py"
  output_path = "${path.module}/build/ssm_backup.zip"
}

resource "aws_iam_role" "lambda" {
  name_prefix = "${local.name_prefix}-lambda-"

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

resource "aws_iam_role_policy" "lambda_inline" {
  name_prefix = "${local.name_prefix}-lambda-inline-"
  role        = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Write backups to the bucket
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:AbortMultipartUpload"
        ]
        Resource = "${aws_s3_bucket.backup.arn}/*"
      },
      # Allow using the KMS key for S3 SSE-KMS
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = aws_kms_key.backup.arn
      },
      # Read SSM parameters
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParameters"
        ]
        Resource = "*"
      },
      # Basic logging
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:*"
      }
    ]
  })
}

resource "aws_lambda_function" "backup" {
  function_name = "${local.name_prefix}-ssm-backup"
  role          = aws_iam_role.lambda.arn
  handler       = "ssm_backup.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = 300
  memory_size = 256

  environment {
    variables = {
      S3_BUCKET   = aws_s3_bucket.backup.bucket
      KMS_KEY_ARN = aws_kms_key.backup.arn
    }
  }

  depends_on = [aws_iam_role_policy.lambda_inline]
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.backup.function_name}"
  retention_in_days = 14
}

# EventBridge schedule to run daily
resource "aws_cloudwatch_event_rule" "schedule" {
  name_prefix         = "${local.name_prefix}-schedule-"
  schedule_expression = var.backup_schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "invoke-lambda"
  arn       = aws_lambda_function.backup.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
