data "aws_caller_identity" "current" {}

locals {
  effective_bucket_name = coalesce(var.s3_bucket_name, "${var.app_name}-${data.aws_caller_identity.current.account_id}")
}

resource "aws_ecr_repository" "lambda" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_role" "lambda" {
  name = "${var.app_name}-lambda-role"

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
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "app" {
  name        = "${var.app_name}-lambda-permissions"
  description = "Permissions for aws-iam-gitops Lambda to read IAM/Organizations and write CloudTrail logs."

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
      },
      {
        Sid    = "CloudTrailBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.cloudtrail.arn,
          "${aws_s3_bucket.cloudtrail.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.app.arn
}

resource "aws_lambda_function" "this" {
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda.arn
  package_type  = "Image"

  # NOTE: You must build and push the image to this ECR repo/tag before apply.
  image_uri = "${aws_ecr_repository.lambda.repository_url}:${var.image_tag}"

  timeout = var.lambda_timeout

  environment {
    variables = {
      GITHUB_USERNAME = var.github_username
      GITHUB_REPO     = var.github_repo
      GITHUB_TOKEN    = var.github_token
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy_attachment.app
  ]
}

resource "aws_cloudwatch_event_rule" "schedule" {
  name                = "${var.app_name}-schedule"
  description         = "Scheduled trigger for ${var.app_name} Lambda"
  schedule_expression = var.eventbridge_schedule_expression
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

resource "aws_s3_bucket" "cloudtrail" {
  bucket        = local.effective_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.cloudtrail,
    aws_s3_bucket_ownership_controls.cloudtrail
  ]
}

resource "aws_cloudtrail" "this" {
  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  depends_on = [aws_s3_bucket_policy.cloudtrail]
}
