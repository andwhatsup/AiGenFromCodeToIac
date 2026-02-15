data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix = substr(replace(var.app_name, "_", "-"), 0, 32)
}

# Minimal, validate-friendly baseline for this repo:
# - S3 bucket for input files
# - DynamoDB table (the lambda code imports dynamodb; table can be used for idempotency/retries)
# - Lambda function (placeholder) wired to S3 events
# - IAM role/policy for Lambda to read S3 + write logs + (optional) DynamoDB

resource "aws_s3_bucket" "input" {
  bucket_prefix = "${local.name_prefix}-input-"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "input" {
  bucket                  = aws_s3_bucket.input.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "events" {
  name         = "${local.name_prefix}-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }
}

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
  name_prefix        = "${local.name_prefix}-lambda-"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid = "AllowLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  statement {
    sid = "AllowReadInputBucket"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.input.arn,
      "${aws_s3_bucket.input.arn}/*"
    ]
  }

  statement {
    sid = "AllowDynamoDB"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [aws_dynamodb_table.events.arn]
  }

  # NOTE: The real application triggers MWAA via create_cli_token and calling the MWAA webserver.
  # MWAA is intentionally not provisioned here to keep the deployment minimal and fast.
  statement {
    sid       = "AllowMwaaCliToken"
    actions   = ["mwaa:CreateCliToken"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${local.name_prefix}-lambda"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

# Package the repo's lambda handler if present; otherwise create a tiny placeholder.
resource "local_file" "lambda_placeholder" {
  filename = "${path.module}/lambda/index.py"
  content  = <<-PY
  import json

  def lambda_handler(event, context):
      return {"statusCode": 200, "body": json.dumps({"ok": True, "event": event})}
  PY
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"

  depends_on = [local_file.lambda_placeholder]
}

resource "aws_lambda_function" "trigger" {
  function_name = "${local.name_prefix}-trigger"
  role          = aws_iam_role.lambda.arn
  handler       = "index.lambda_handler"
  runtime       = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = 30

  environment {
    variables = {
      LOG_LEVEL     = var.log_level
      MWAA_ENV_NAME = "placeholder"
      DDB_TABLE     = aws_dynamodb_table.events.name
      INPUT_BUCKET  = aws_s3_bucket.input.id
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input.arn
}

resource "aws_s3_bucket_notification" "input" {
  bucket = aws_s3_bucket.input.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
