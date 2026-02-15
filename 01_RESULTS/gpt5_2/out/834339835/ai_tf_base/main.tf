resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  bucket_name = lower(replace("${var.app_name}-${random_id.suffix.hex}", "_", "-"))
}

# Minimal, conservative baseline for a static HTML/CSS/JS app.
# This repo contains index.html + style.css and can be hosted as an S3 static website.

resource "aws_s3_bucket" "site" {
  count  = var.enable_static_site ? 1 : 0
  bucket = local.bucket_name

  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "site" {
  count  = var.enable_static_site ? 1 : 0
  bucket = aws_s3_bucket.site[0].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  count  = var.enable_static_site ? 1 : 0
  bucket = aws_s3_bucket.site[0].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "site" {
  count  = var.enable_static_site ? 1 : 0
  bucket = aws_s3_bucket.site[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "site" {
  count  = var.enable_static_site ? 1 : 0
  bucket = aws_s3_bucket.site[0].id
  acl    = "public-read"

  depends_on = [
    aws_s3_bucket_public_access_block.site,
    aws_s3_bucket_ownership_controls.site,
  ]
}

data "aws_iam_policy_document" "public_read" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    resources = ["${aws_s3_bucket.site[0].arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  count  = var.enable_static_site ? 1 : 0
  bucket = aws_s3_bucket.site[0].id
  policy = data.aws_iam_policy_document.public_read.json

  depends_on = [aws_s3_bucket_public_access_block.site]
}
