locals {
  name_prefix = var.app_name
}

resource "aws_s3_bucket" "artifacts" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = "${local.name_prefix}-artifacts"

  # Keep it simple for LocalStack; in real AWS you may want versioning, encryption, etc.
  force_destroy = true
}

resource "aws_dynamodb_table" "example" {
  count        = var.create_dynamodb_table ? 1 : 0
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }
}
