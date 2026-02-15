locals {
  # This repository contains a simple static website (index.html + app.js + style.css)
  # and a Dockerfile that serves it via nginx. The minimal AWS infra to run it is
  # an S3 bucket configured for static website hosting.
  bucket_name = coalesce(var.bucket_name, "${var.app_name}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}")
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_s3_bucket" "site" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Public read policy for website content.
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id

  depends_on = [aws_s3_bucket_public_access_block.site]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.site.arn}/*"]
      }
    ]
  })
}
