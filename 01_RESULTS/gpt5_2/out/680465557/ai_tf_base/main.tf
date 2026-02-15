data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

locals {
  name = var.app_name
}

# Package the lambda function from the repository source.
# This uses a zip-based Lambda (simpler to validate/apply than container image + ECR).

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/build/lambda.zip"

  source {
    content = templatefile("${path.module}/lambda_function.py.tftpl", {
      github_username = var.github_username
      github_repo     = var.github_repo
      github_token    = var.github_token
    })
    filename = "lambda_function.py"
  }
}

resource "aws_iam_role" "lambda" {
  name = "${local.name}-lambda-role"

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

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Minimal permissions required by the function code:
# - IAM list roles/policies
# - Organizations list/describe SCPs
resource "aws_iam_policy" "lambda_permissions" {
  name        = "${local.name}-lambda-permissions"
  description = "Permissions for aws-iam-gitops lambda to read IAM and Organizations SCPs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IamRead"
        Effect = "Allow"
        Action = [
          "iam:ListRoles",
          "iam:ListPolicies"
        ]
        Resource = "*"
      },
      {
        Sid    = "OrgsRead"
        Effect = "Allow"
        Action = [
          "organizations:ListPolicies",
          "organizations:DescribePolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_permissions" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_permissions.arn
}

resource "aws_lambda_function" "this" {
  function_name = local.name
  role          = aws_iam_role.lambda.arn

  runtime = "python3.11"
  handler = "lambda_function.handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout = var.lambda_timeout
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${local.name}-schedule"
  description         = "Schedule to run ${local.name}"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "lambda"
  arn       = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
