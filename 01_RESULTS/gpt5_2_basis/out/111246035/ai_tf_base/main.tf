locals {
  name_prefix = var.app_name
}

# Minimal baseline infrastructure for this repository.
#
# The application is a small Go binary (also containerizable) that periodically
# fetches an auth map from a URI and writes an authorized_keys file.
# There is no HTTP server to expose, so the minimal AWS footprint is an S3
# bucket to store artifacts/config (e.g., authmap) and an IAM policy document
# that can be attached to a compute role if you later run this on ECS/EC2.

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${local.name_prefix}-artifacts-"
  force_destroy = var.artifact_bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket                  = aws_s3_bucket.artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "read_artifacts_bucket" {
  statement {
    sid     = "ListBucket"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = [
      aws_s3_bucket.artifacts.arn
    ]
  }

  statement {
    sid     = "GetObjects"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "read_artifacts_bucket" {
  name_prefix = "${local.name_prefix}-read-artifacts-"
  description = "Read-only access to the ${local.name_prefix} artifacts bucket (for fetching authmap/config)."
  policy      = data.aws_iam_policy_document.read_artifacts_bucket.json
}
