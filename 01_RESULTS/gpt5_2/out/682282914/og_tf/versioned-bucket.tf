resource "aws_s3_bucket" "versionedexample" {
  bucket = "versionedexample"
}

resource "aws_s3_bucket_versioning" "versionedexample" {
  bucket = aws_s3_bucket.versionedexample.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "versionedbucketfiles" {
  depends_on   = [aws_s3_bucket.versionedexample]
  for_each     = fileset("${path.root}", "versioned-bucket-files/*.html")
  bucket       = "versionedexample"
  key          = basename(each.value)
  source       = each.value
  etag         = filemd5("${each.value}")
  content_type = "text/html"
  acl          = "public-read"
}