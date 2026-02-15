resource "aws_s3_bucket" "artifacts_bucket" {
  bucket        = "${var.app_name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Name        = "${var.app_name}-artifacts"
    Environment = "dev"
  }
}

