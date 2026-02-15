resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.app_name}-bucket"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-bucket"
  }
}

resource "aws_sqs_queue" "app_queue" {
  name = "${var.app_name}-queue"
  tags = {
    Name = "${var.app_name}-queue"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.app_name}-lambda-exec"
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

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "app_lambda" {
  function_name    = "${var.app_name}-lambda"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "handler"
  runtime          = "go1.x"
  filename         = "dummy_lambda.zip" # Placeholder, user must provide zip
  source_code_hash = "dummyhash"        # Skipped for validation
  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.app_queue.id
    }
  }
  tags = {
    Name = "${var.app_name}-lambda"
  }
}

resource "aws_lambda_event_source_mapping" "sqs_event" {
  event_source_arn = aws_sqs_queue.app_queue.arn
  function_name    = aws_lambda_function.app_lambda.arn
  enabled          = true
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.app_bucket.id
  queue {
    queue_arn = aws_sqs_queue.app_queue.arn
    events    = ["s3:ObjectCreated:*"]
  }
}
