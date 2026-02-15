resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "ssm_backup" {
  bucket        = "${var.namespace}-${var.environment}-ssm-backup-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags = {
    Name        = "${var.namespace}-${var.environment}-ssm-backup"
    Environment = var.environment
    Project     = var.namespace
  }
}

resource "aws_kms_key" "ssm_backup" {
  description             = "KMS key for encrypting SSM backup files in S3"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = {
    Name        = "${var.namespace}-${var.environment}-ssm-backup-kms"
    Environment = var.environment
    Project     = var.namespace
  }
}

resource "aws_iam_role" "lambda" {
  name = "${var.namespace}-${var.environment}-ssm-backup-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  tags = {
    Name        = "${var.namespace}-${var.environment}-ssm-backup-lambda-role"
    Environment = var.environment
    Project     = var.namespace
  }
}

resource "aws_iam_policy" "lambda" {
  name        = "${var.namespace}-${var.environment}-ssm-backup-lambda-policy"
  description = "Policy for Lambda to access SSM, S3, and KMS"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:DescribeParameters",
          "ssm:GetParameters",
          "ssm:GetParameter*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.ssm_backup.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "${aws_kms_key.ssm_backup.arn}"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_lambda_function" "ssm_backup" {
  function_name    = "${var.namespace}-${var.environment}-ssm-backup"
  role             = aws_iam_role.lambda.arn
  handler          = "ssm_backup.lambda_handler"
  runtime          = "python3.9"
  filename         = local.lambda_dummy_zip
  source_code_hash = data.archive_file.lambda_dummy.output_base64sha256
  environment {
    variables = {
      S3_BUCKET   = aws_s3_bucket.ssm_backup.bucket
      KMS_KEY_ARN = aws_kms_key.ssm_backup.arn
    }
  }
  tags = {
    Name        = "${var.namespace}-${var.environment}-ssm-backup-lambda"
    Environment = var.environment
    Project     = var.namespace
  }
}

resource "aws_cloudwatch_event_rule" "daily" {
  name                = "${var.namespace}-${var.environment}-ssm-backup-daily"
  schedule_expression = "rate(1 day)"
  tags = {
    Name        = "${var.namespace}-${var.environment}-ssm-backup-daily"
    Environment = var.environment
    Project     = var.namespace
  }
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.daily.name
  target_id = "lambda"
  arn       = aws_lambda_function.ssm_backup.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ssm_backup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily.arn
}
