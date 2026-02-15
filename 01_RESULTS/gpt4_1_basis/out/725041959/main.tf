resource "random_pet" "bucket_name" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "${var.app_name}-${random_pet.bucket_name.id}"
  force_destroy = true
  tags = {
    Name        = var.app_name
    Environment = "dev"
  }
}
