resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-terraform-bucket" # Replace with your desired bucket name
  tags = {
    Environment = var.env
  }
}