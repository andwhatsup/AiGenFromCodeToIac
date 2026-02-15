# Minimal baseline: S3 bucket for artifacts/static assets
resource "aws_s3_bucket" "app_bucket" {
  bucket        = "${var.app_name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name        = var.app_name
    Environment = "dev"
  }
}

