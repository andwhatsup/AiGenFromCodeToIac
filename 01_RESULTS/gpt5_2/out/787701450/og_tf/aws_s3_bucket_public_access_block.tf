resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id
}
