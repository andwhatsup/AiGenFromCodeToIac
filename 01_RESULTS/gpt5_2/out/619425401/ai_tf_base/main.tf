data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix = var.app_name
}

resource "aws_dynamodb_table" "lock" {
  name         = "${local.name_prefix}-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "key"

  attribute {
    name = "key"
    type = "S"
  }
}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${local.name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
}

data "aws_iam_policy_document" "lambda_policy" {
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
    sid    = "AllowDynamoDBLocking"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable"
    ]
    resources = [aws_dynamodb_table.lock.arn]
  }

  statement {
    sid    = "AllowS3AccessToDatalake"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${local.name_prefix}-policy"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_lambda_function" "this" {
  function_name = local.name_prefix
  role          = aws_iam_role.lambda.arn

  # In evaluation/CI environments the real artifact may not exist.
  # Fall back to a small dummy zip generated in _eval_override_lambda_dummy.tf.
  filename         = fileexists(var.lambda_zip_path) ? var.lambda_zip_path : data.archive_file.lambda_dummy.output_path
  source_code_hash = filebase64sha256(fileexists(var.lambda_zip_path) ? var.lambda_zip_path : data.archive_file.lambda_dummy.output_path)

  runtime = "provided.al2"
  handler = "bootstrap"

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      DATALAKE_LOCATION        = var.datalake_location
      AWS_S3_LOCKING_PROVIDER  = "dynamodb"
      OPTIMIZE_DS              = var.optimize_ds
      DYNAMODB_LOCK_TABLE_NAME = aws_dynamodb_table.lock.name
    }
  }

  depends_on = [aws_iam_role_policy.lambda_inline]
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.name_prefix}-daily"
  description         = "Periodic trigger for ${local.name_prefix}"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromCloudWatchEvents"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
