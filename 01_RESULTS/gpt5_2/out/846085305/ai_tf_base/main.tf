locals {
  ecr_repo_name = var.app_name
  lambda_name   = "${var.app_name}-collector"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_ecr_repository" "app" {
  name                 = local.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "lambda" {
  name = "${local.lambda_name}-role"

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

resource "aws_lambda_function" "collector" {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"

  # Image must be built and pushed separately:
  # docker build -t ${var.app_name} .
  # docker tag ${var.app_name}:${var.lambda_image_tag} ${aws_ecr_repository.app.repository_url}:${var.lambda_image_tag}
  # docker push ${aws_ecr_repository.app.repository_url}:${var.lambda_image_tag}
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

  depends_on = [aws_iam_role_policy_attachment.lambda_basic]
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.lambda_name}-schedule"
  schedule_expression = var.lambda_schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.collector.arn
}

resource "aws_lambda_permission" "allow_events" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.collector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
