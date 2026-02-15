locals {
  # number of invocations = duration / interval
  invocation_count = floor(var.duration_seconds / var.interval_seconds)

  # Step Functions state machine definition (based on repo's definition.json)
  sfn_definition = jsonencode({
    Comment = "Invoke Lambda every ${var.interval_seconds} seconds"
    StartAt = "ConfigureCount"
    States = {
      ConfigureCount = {
        Type = "Pass"
        Result = {
          index = 0
          count = local.invocation_count
        }
        ResultPath = "$.iterator"
        Next       = "Iterator"
      }
      Iterator = {
        Type       = "Task"
        Resource   = aws_lambda_function.iterator.arn
        ResultPath = "$.iterator"
        Next       = "IsCountReached"
      }
      IsCountReached = {
        Type = "Choice"
        Choices = [
          {
            Variable      = "$.iterator.continue"
            BooleanEquals = true
            Next          = "Wait"
          }
        ]
        Default = "Done"
      }
      Wait = {
        Type    = "Wait"
        Seconds = var.interval_seconds
        Next    = "Iterator"
      }
      Done = {
        Type = "Pass"
        End  = true
      }
    }
  })
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

# --- IAM for iterator lambda ---
resource "aws_iam_role" "iterator" {
  name = "${var.app_name}-iterator-role"
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

resource "aws_iam_role_policy_attachment" "iterator_basic" {
  role       = aws_iam_role.iterator.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "iterator_invoke_target" {
  name = "${var.app_name}-iterator-invoke-target"
  role = aws_iam_role.iterator.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = var.target_lambda_arn
      }
    ]
  })
}

# --- Iterator lambda (placeholder zip so terraform validates without build tooling) ---
resource "aws_lambda_function" "iterator" {
  function_name = "${var.app_name}-iterator"
  role          = aws_iam_role.iterator.arn

  runtime = "provided.al2023"
  handler = "bootstrap"

  filename         = "${path.module}/lambda_placeholder.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_placeholder.zip")

  environment {
    variables = {
      REGION = var.aws_region
      LAMBDA = var.target_lambda_arn
    }
  }
}

# --- Step Functions ---
resource "aws_iam_role" "sfn" {
  name = "${var.app_name}-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sfn_invoke_iterator" {
  name = "${var.app_name}-sfn-invoke-iterator"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:InvokeFunction"
        ]
        Resource = aws_lambda_function.iterator.arn
      }
    ]
  })
}

resource "aws_sfn_state_machine" "hfl" {
  name       = "${var.app_name}-state-machine"
  role_arn   = aws_iam_role.sfn.arn
  definition = local.sfn_definition
}
