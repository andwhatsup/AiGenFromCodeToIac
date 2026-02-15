resource "aws_s3_bucket_accelerate_configuration" "main" {
  bucket                = aws_s3_bucket.main.id
  expected_bucket_owner = data.aws_caller_identity.main.account_id
  status                = "Suspended"
}
