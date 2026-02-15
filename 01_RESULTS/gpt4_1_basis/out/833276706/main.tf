resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.app_name}-bucket-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name        = var.app_name
    Environment = "dev"
  }
}

