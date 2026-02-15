resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.app_name}-artifacts-${random_id.bucket_id.hex}"
  force_destroy = true
  tags = {
    Name        = "${var.app_name}-artifacts"
    Environment = "dev"
  }
}

