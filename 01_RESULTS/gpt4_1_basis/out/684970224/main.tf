resource "aws_s3_bucket" "app_artifacts" {
  bucket        = "${var.app_name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name        = var.app_name
    Environment = "dev"
  }
}

