resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "etl_data" {
  bucket = var.bucket_name

  tags = {
    Name        = "etl-pipeline-artifacts"
    Environment = "dev"
  }
}

