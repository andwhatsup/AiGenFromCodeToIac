locals {
  name_prefix = var.app_name
}

# Minimal, conservative baseline infrastructure.
# The upstream repository is a Terraform module for provisioning FreeIPA in a
# larger COOL shared-services environment with multiple remote states.
# Since this codebase does not include runnable application code (no Dockerfile,
# no web service), we provision a small set of foundational AWS resources that
# validate and can be applied in most AWS accounts.

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${local.name_prefix}-artifacts-"

  tags = {
    Name = "${local.name_prefix}-artifacts"
  }
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

# Optional state-lock style table (useful for Terraform state locking patterns).
resource "aws_dynamodb_table" "tf_lock" {
  name         = "${local.name_prefix}-tf-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${local.name_prefix}-tf-lock"
  }
}

# IAM role/policy stub that could be extended for provisioning FreeIPA-related resources.
# This is intentionally minimal and does not grant permissions by default.
resource "aws_iam_role" "app" {
  name_prefix = "${local.name_prefix}-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${local.name_prefix}-role"
  }
}

resource "aws_iam_policy" "app" {
  name_prefix = "${local.name_prefix}-policy-"
  description = "Minimal policy stub for ${var.app_name}."

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = []
  })
}

resource "aws_iam_role_policy_attachment" "app" {
  role       = aws_iam_role.app.name
  policy_arn = aws_iam_policy.app.arn
}
