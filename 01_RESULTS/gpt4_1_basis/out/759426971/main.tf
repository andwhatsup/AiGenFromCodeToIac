# Minimal baseline infrastructure for LocalStack/Dev
resource "aws_s3_bucket" "artifact" {
  bucket        = "${var.app_name}-artifact-bucket"
  force_destroy = true
  tags = {
    Name        = "${var.app_name}-artifact"
    Environment = "dev"
  }
}

resource "aws_dynamodb_table" "state" {
  name         = "${var.app_name}-state-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }
  tags = {
    Name        = "${var.app_name}-state"
    Environment = "dev"
  }
}
