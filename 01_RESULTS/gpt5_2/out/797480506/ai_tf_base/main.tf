locals {
  # Keep names deterministic but unique when bucket name isn't provided.
  bucket_name = coalesce(var.artifact_bucket_name, "${var.app_name}-artifacts-${random_id.bucket_suffix.hex}")
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role that Step Functions uses to call Rekognition and access S3.
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

resource "aws_iam_policy" "sfn_policy" {
  name        = "${var.app_name}-sfn-policy"
  description = "Allow Step Functions to call Rekognition and read/write artifacts bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Rekognition"
        Effect = "Allow"
        Action = [
          "rekognition:DetectLabels",
          "rekognition:DetectText",
          "rekognition:DetectFaces",
          "rekognition:DetectModerationLabels",
          "rekognition:DetectProtectiveEquipment"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3Artifacts"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.artifacts.arn,
          "${aws_s3_bucket.artifacts.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "sfn_attach" {
  role       = aws_iam_role.sfn_role.name
  policy_arn = aws_iam_policy.sfn_policy.arn
}

# Minimal Step Functions state machine placeholder.
# The repository contains ASL JSON definitions, but they reference other resources
# (e.g., SQS/Lambda) that are not present in this repo. This keeps the deployment
# minimal and valid while still provisioning a state machine.
resource "aws_sfn_state_machine" "rekognition" {
  name     = "${var.app_name}-rekognition"
  role_arn = aws_iam_role.sfn_role.arn

  definition = jsonencode({
    Comment = "Minimal placeholder state machine for AWS Rekognition pipeline"
    StartAt = "Success"
    States = {
      Success = {
        Type = "Succeed"
      }
    }
  })
}
