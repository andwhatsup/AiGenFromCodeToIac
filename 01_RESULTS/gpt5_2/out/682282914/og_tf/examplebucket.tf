resource "aws_s3_bucket" "examplebucket" {
  bucket = "examplebucket"
}

resource "aws_s3_bucket_website_configuration" "examplebucket" {
  bucket = aws_s3_bucket.examplebucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "examplebucket" {
  bucket = aws_s3_bucket.examplebucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.examplebucket.arn,
          "${aws_s3_bucket.examplebucket.arn}/*",
        ]
      },
    ]
  })
}

# Note: index.html is intentionally manual to demo the aws s3 CLI.
# This demos copying files using Terraform
resource "aws_s3_object" "examplebucketfiles" {
  depends_on   = [aws_s3_bucket.examplebucket]
  for_each     = fileset("${path.root}", "bucket-files/*.html")
  bucket       = "examplebucket"
  key          = basename(each.value)
  source       = each.value
  etag         = filemd5("${each.value}")
  content_type = "text/html"
  acl          = "public-read"
}