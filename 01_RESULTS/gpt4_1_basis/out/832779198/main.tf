resource "aws_s3_bucket" "lambda_events" {
  bucket        = "${var.app_name}-lambda-events-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name = "${var.app_name}-lambda-events"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_notification" "lambda_trigger" {
  bucket = aws_s3_bucket.lambda_events.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.app_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "source/"
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}-lambda-exec-role"
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
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.app_name}-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.lambda_events.arn,
          "${aws_s3_bucket.lambda_events.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "app_lambda" {
  function_name    = "${var.app_name}-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  filename         = local.lambda_dummy_zip
  source_code_hash = data.archive_file.lambda_dummy.output_base64sha256
  environment {
    variables = {
      BUCKET = aws_s3_bucket.lambda_events.bucket
    }
  }
  tags = {
    Name = "${var.app_name}-lambda"
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_events.arn
}
