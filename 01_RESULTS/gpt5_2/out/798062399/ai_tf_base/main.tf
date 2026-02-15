locals {
  # The repository contains a static HTML/CSS/JS notes app.
  # Minimal AWS infra: S3 static website hosting.
  origin_id = "s3-${var.app_name}"
}

resource "aws_s3_bucket" "site" {
  bucket_prefix = "${var.app_name}-site-"
  force_destroy = var.bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
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

# Allow public read of objects for website hosting.
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id

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

  depends_on = [aws_s3_bucket_public_access_block.site]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/../index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../index.html")
}

resource "aws_s3_object" "script" {
  bucket       = aws_s3_bucket.site.id
  key          = "script.js"
  source       = "${path.module}/../script.js"
  content_type = "application/javascript"
  etag         = filemd5("${path.module}/../script.js")
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.site.id
  key          = "style.css"
  source       = "${path.module}/../style.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/../style.css")
}
