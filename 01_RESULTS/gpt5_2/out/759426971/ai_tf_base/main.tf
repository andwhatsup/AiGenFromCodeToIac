resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-artifacts"
  force_destroy = true
}

resource "aws_dynamodb_table" "app" {
  name         = "${var.app_name}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "pk"

  attribute {
    name = "pk"
    type = "S"
  }
}
