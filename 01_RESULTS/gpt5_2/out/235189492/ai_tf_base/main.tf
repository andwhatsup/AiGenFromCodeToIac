data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

locals {
  iterator_lambda_name = "${var.app_name}-iterator"
  sfn_name             = "${var.app_name}-iterator"
}

# Package a minimal Lambda (Node.js) that invokes the target Lambda asynchronously.
# This avoids requiring a Go build toolchain during terraform apply.
resource "local_file" "iterator_source" {
  filename = "${path.module}/lambda/index.mjs"
  content  = <<-EOT
    import { LambdaClient, InvokeCommand } from "@aws-sdk/client-lambda";

    export const handler = async (event) => {
      const iterator = event?.iterator ?? { index: 0, count: 0 };
      const index = (iterator.index ?? 0) + 1;
      const count = iterator.count ?? 0;

      const region = process.env.REGION;
      const fnArn = process.env.TARGET_LAMBDA_ARN;
      if (!region) throw new Error("REGION missing");
      if (!fnArn) throw new Error("TARGET_LAMBDA_ARN missing");

      const client = new LambdaClient({ region });
      await client.send(new InvokeCommand({
        FunctionName: fnArn,
        InvocationType: "Event"
      }));

      return {
        index,
        count,
        continue: index < count
      };
    };
  EOT
}

data "archive_file" "iterator_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"

  depends_on = [local_file.iterator_source]
}

resource "aws_iam_role" "iterator_lambda_role" {
  name = "${var.app_name}-iterator-lambda-role"
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

resource "aws_iam_role_policy" "iterator_lambda_policy" {
  name = "${var.app_name}-iterator-lambda-policy"
  role = aws_iam_role.iterator_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowInvokeTargetLambda"
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = [
          var.target_lambda_arn
        ]
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "iterator" {
  function_name = local.iterator_lambda_name
  role          = aws_iam_role.iterator_lambda_role.arn

  runtime = "nodejs20.x"
  handler = "index.handler"

  filename         = data.archive_file.iterator_zip.output_path
  source_code_hash = data.archive_file.iterator_zip.output_base64sha256

  timeout = 30

  environment {
    variables = {
      REGION            = var.aws_region
      TARGET_LAMBDA_ARN = var.target_lambda_arn
    }
  }
}

resource "aws_cloudwatch_log_group" "iterator" {
  name              = "/aws/lambda/${aws_lambda_function.iterator.function_name}"
  retention_in_days = 14
}

resource "aws_iam_role" "sfn_role" {
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

resource "aws_iam_role_policy" "sfn_policy" {
  name = "${var.app_name}-sfn-policy"
  role = aws_iam_role.sfn_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowInvokeIteratorLambda"
        Effect = "Allow"
        Action = ["lambda:InvokeFunction"]
        Resource = [
          aws_lambda_function.iterator.arn
        ]
      }
    ]
  })
}

resource "aws_sfn_state_machine" "iterator" {
  name     = local.sfn_name
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    Comment = "Invoke Lambda every ${var.interval_seconds} seconds"
    StartAt = "ConfigureCount"
    States = {
      ConfigureCount = {
        Type = "Pass"
        Result = {
          index = 0
          count = var.invocations_per_execution
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
