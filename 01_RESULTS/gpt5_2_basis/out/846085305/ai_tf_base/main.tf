locals {
  name_prefix = var.app_name
}

resource "aws_ecr_repository" "app" {
  name                 = local.name_prefix
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Keep it minimal: allow Lambda to write logs.
resource "aws_iam_role" "lambda" {
  name = "${local.name_prefix}-lambda-role"

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
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name_prefix}"
  retention_in_days = 14
}

resource "aws_lambda_function" "app" {
  function_name = local.name_prefix
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"

  # Image must be pushed separately after ECR is created.
  image_uri = "${aws_ecr_repository.app.repository_url}:${var.lambda_image_tag}"

  timeout     = 60
  memory_size = 256

  environment {
    variables = {
      INFLUXDB_URL    = var.influxdb_url
      INFLUXDB_TOKEN  = var.influxdb_token
      INFLUXDB_ORG    = var.influxdb_org
      INFLUXDB_BUCKET = var.influxdb_bucket
      TUYA_APIKEY     = var.tuya_apikey
      TUYA_APISECRET  = var.tuya_apisecret
      TUYA_APISREGION = var.tuya_apisregion
    }
  }

  depends_on = [aws_cloudwatch_log_group.lambda]
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.name_prefix}-schedule"
  description         = "Periodic trigger for ${local.name_prefix} Lambda"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.app.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
