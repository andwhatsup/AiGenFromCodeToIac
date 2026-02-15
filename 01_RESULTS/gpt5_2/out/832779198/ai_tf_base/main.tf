locals {
  common_tags = merge(
    {
      Application = var.app_name
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "app" {
  bucket_prefix = "${var.app_name}-"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "lambda" {
  name_prefix = "${var.app_name}-lambda-"

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

  tags = local.common_tags
}

resource "aws_iam_role_policy" "lambda" {
  name_prefix = "${var.app_name}-lambda-"
  role        = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLogging"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowS3Move"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.app.arn,
          "${aws_s3_bucket.app.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "mover" {
  function_name = "${var.app_name}-s3-mover"
  role          = aws_iam_role.lambda.arn

  runtime = "python3.11"
  handler = "lambda_function.lambda_handler"

  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)

  environment {
    variables = {
      BUCKET = aws_s3_bucket.app.bucket
    }
  }

  tags = local.common_tags
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mover.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.app.arn
}

resource "aws_s3_bucket_notification" "app" {
  bucket = aws_s3_bucket.app.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.mover.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.source_prefix
  }

  depends_on = [aws_lambda_permission.allow_s3]
}
