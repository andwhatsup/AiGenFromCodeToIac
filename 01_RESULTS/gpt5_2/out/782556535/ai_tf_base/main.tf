locals {
  # Keep names deterministic and compatible with S3 naming rules.
  # Terratest passes a globally-unique name already.
  bucket_name      = var.tag_bucket_name
  logs_bucket_name = "${var.tag_bucket_name}-logs"
}

resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = true

  tags = {
    Name        = var.tag_bucket_name
    Environment = var.tag_bucket_environment
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket        = local.logs_bucket_name
  force_destroy = true

  tags = {
    Name        = local.logs_bucket_name
    Environment = var.tag_bucket_environment
  }
}

resource "aws_s3_bucket_logging" "main" {
  bucket        = aws_s3_bucket.main.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "TFStateLogs/"
}

data "aws_iam_policy_document" "main_bucket_policy" {
  statement {
    sid     = "AllowGetBucketLocation"
    effect  = "Allow"
    actions = ["s3:GetBucketLocation"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_s3_bucket.main.arn]
  }
}

resource "aws_s3_bucket_policy" "main" {
  count  = var.with_policy ? 1 : 0
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main_bucket_policy.json
}
