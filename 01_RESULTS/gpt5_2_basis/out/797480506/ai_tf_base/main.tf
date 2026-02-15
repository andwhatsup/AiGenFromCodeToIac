locals {
  name_prefix = var.app_name
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Minimal artifact bucket (useful for images/results if you extend the pipeline)
resource "aws_s3_bucket" "artifacts" {
  bucket        = "${local.name_prefix}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for Step Functions
data "aws_iam_policy_document" "sfn_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "sfn" {
  name               = "${local.name_prefix}-sfn-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume.json
}

# Minimal permissions for the state machine to call Rekognition APIs.
# (The provided ASL definitions in this repo are primarily input-validation logic;
# this policy is a conservative baseline for extending with Rekognition Task states.)
data "aws_iam_policy_document" "sfn_policy" {
  statement {
    sid    = "RekognitionReadWrite"
    effect = "Allow"
    actions = [
      "rekognition:DetectLabels",
      "rekognition:DetectFaces",
      "rekognition:DetectText",
      "rekognition:DetectModerationLabels",
      "rekognition:DetectProtectiveEquipment"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3Artifacts"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }

  # Allow Step Functions to write execution logs to CloudWatch Logs if enabled later.
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "sfn_inline" {
  name   = "${local.name_prefix}-sfn-policy"
  role   = aws_iam_role.sfn.id
  policy = data.aws_iam_policy_document.sfn_policy.json
}

# Step Functions state machine using the repo's definition
resource "aws_sfn_state_machine" "rekognition" {
  name       = "${local.name_prefix}-${random_id.suffix.hex}"
  role_arn   = aws_iam_role.sfn.arn
  definition = file(var.state_machine_definition_path)
}
