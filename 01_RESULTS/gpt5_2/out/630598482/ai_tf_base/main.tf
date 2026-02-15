resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  name_prefix = substr(replace(var.app_name, "_", "-"), 0, 32)
}

# Minimal baseline infrastructure for this repo:
# - The application is a Pynecone (Reflex) web app that runs as a Python process and
#   uses Google OAuth (client_secret.json) and a local sqlite DB by default.
# - No Dockerfile/compose is present, and no clear production hosting target is defined.
# - To keep this minimal and broadly compatible (including LocalStack-style envs),
#   we provision an S3 bucket for build artifacts/static exports and a least-privilege
#   IAM role/policy stub that could be assumed by a CI/CD system.

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
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["sts:AssumeRole"]

    # NOTE: This is a stub. In real usage, restrict by principal ARN(s) or OIDC.
  }
}

resource "aws_iam_role" "cicd" {
  name               = "${local.name_prefix}-cicd-${random_id.suffix.hex}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cicd" {
  statement {
    sid    = "S3ArtifactsRW"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "cicd" {
  name   = "${local.name_prefix}-cicd-${random_id.suffix.hex}"
  policy = data.aws_iam_policy_document.cicd.json
}

resource "aws_iam_role_policy_attachment" "cicd" {
  role       = aws_iam_role.cicd.name
  policy_arn = aws_iam_policy.cicd.arn
}
