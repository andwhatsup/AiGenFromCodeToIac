resource "aws_s3_bucket_object" "index_html" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "index.html"
  source       = "../index.html"
  acl          = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "script_js" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "script.js"
  source       = "../script.js"
  acl          = "public-read"
  content_type = "application/javascript"
}

resource "aws_s3_bucket_object" "style_css" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "style.css"
  source       = "../style.css"
  acl          = "public-read"
  content_type = "text/css"
}

resource "aws_s3_bucket_object" "cactus_png" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "images/cactus.png"
  source       = "../images/cactus.png"
  acl          = "public-read"
  content_type = "image/png"
}

resource "aws_s3_bucket_object" "dinosaur_png" {
  bucket       = aws_s3_bucket.static_site.id
  key          = "images/dinosaur.png"
  source       = "../images/dinosaur.png"
  acl          = "public-read"
  content_type = "image/png"
}
