module "playwright_lambda" {
  source = "github.com/cds-snc/terraform-modules//lambda?ref=v9.6.2"

  name      = "playwright-lambda"
  ecr_arn   = aws_ecr_repository.playwright_lambda.arn
  image_uri = "${aws_ecr_repository.playwright_lambda.repository_url}:latest"
  memory    = 2048
  timeout   = 300

  billing_tag_value = "sre"
}

resource "aws_ecr_repository" "playwright_lambda" {
  name                 = "playwright-lambda"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    CostCentre = "sre"
    Terraform  = true
  }
}

resource "aws_lambda_permission" "eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = module.playwright_lambda.function_name
  source_arn    = aws_cloudwatch_event_rule.every_15_minutes.arn
}

resource "aws_cloudwatch_event_rule" "every_15_minutes" {
  name                = "every-15-minutes"
  description         = "Trigger every 15 minutes"
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "playwright_lambda" {
  target_id = "playwright-lambda"
  rule      = aws_cloudwatch_event_rule.every_15_minutes.name
  arn       = module.playwright_lambda.function_arn

  input = jsonencode({
    url = var.form_url
  })
}
