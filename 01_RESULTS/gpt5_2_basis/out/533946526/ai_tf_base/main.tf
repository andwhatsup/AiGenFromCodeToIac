resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = substr(replace(lower(var.app_name), "_", "-"), 0, 32)
}

# Minimal baseline infrastructure:
# - S3 bucket for artifacts (e.g., kubeconfig, RKE/Rancher assets, logs)
# - IAM role/policy stub that can be extended for automation

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${local.name_prefix}-artifacts-${random_id.suffix.hex}"
  force_destroy = var.artifact_bucket_force_destroy
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

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "automation" {
  name               = "${local.name_prefix}-automation-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "automation" {
  statement {
    sid    = "S3ArtifactsReadWrite"
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "automation" {
  name   = "${local.name_prefix}-automation-${random_id.suffix.hex}"
  policy = data.aws_iam_policy_document.automation.json
}

resource "aws_iam_role_policy_attachment" "automation" {
  role       = aws_iam_role.automation.name
  policy_arn = aws_iam_policy.automation.arn
}
