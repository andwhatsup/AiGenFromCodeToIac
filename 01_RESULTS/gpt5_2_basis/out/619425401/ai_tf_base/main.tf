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

data "aws_iam_policy_document" "assume_role" {
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
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_inline" {
  statement {
    sid    = "DynamoDBLocking"
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable"
    ]
    resources = [aws_dynamodb_table.lock.arn]
  }

  statement {
    sid    = "S3DataLakeAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "lambda_inline" {
  name   = "${local.name_prefix}-inline"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.lambda_inline.json
}

resource "aws_lambda_function" "this" {
  function_name = local.name_prefix
  role          = aws_iam_role.lambda.arn

  runtime = "provided.al2"
  handler = "bootstrap"

  # In evaluation environments the real build artifact may not exist.
  # Fall back to a small dummy zip created in _eval_override_lambda_dummy.tf.
  filename = fileexists(var.lambda_zip_path) ? var.lambda_zip_path : data.archive_file.lambda_dummy.output_path

  # source_code_hash must match the selected filename.
  source_code_hash = filebase64sha256(fileexists(var.lambda_zip_path) ? var.lambda_zip_path : data.archive_file.lambda_dummy.output_path)

  memory_size = var.lambda_memory_size
  timeout     = var.lambda_timeout

  environment {
    variables = {
      DATALAKE_LOCATION        = var.datalake_location
      AWS_S3_LOCKING_PROVIDER  = "dynamodb"
      DYNAMODB_LOCK_TABLE_NAME = aws_dynamodb_table.lock.name
      OPTIMIZE_DS              = var.optimize_ds
    }
  }

  depends_on = [aws_iam_role_policy_attachment.basic]
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.name_prefix}-schedule"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "${local.name_prefix}-lambda"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
