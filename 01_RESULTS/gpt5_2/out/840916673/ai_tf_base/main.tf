locals {
  name_prefix = var.app_name
}

resource "aws_s3_bucket" "static_site" {
  bucket_prefix = "${local.name_prefix}-site-"
  force_destroy = var.bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_website_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_versioning" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static_site" {
  bucket = aws_s3_bucket.static_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Upload the static assets from the repository root.
# This keeps the infrastructure minimal and avoids needing compute.
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  source       = "${path.module}/../index.html"
  content_type = "text/html"

  etag = filemd5("${path.module}/../index.html")
}

resource "aws_s3_object" "script" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "script2.js"
  source       = "${path.module}/../script2.js"
  content_type = "application/javascript"

  etag = filemd5("${path.module}/../script2.js")
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "style2.css"
  source       = "${path.module}/../style2.css"
  content_type = "text/css"

  etag = filemd5("${path.module}/../style2.css")
}
