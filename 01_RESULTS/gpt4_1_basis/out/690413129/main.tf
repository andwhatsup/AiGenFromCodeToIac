resource "random_pet" "mlflow_artifacts" {
  length    = 2
  separator = "-"
}

resource "aws_s3_bucket" "mlflow_artifacts" {
  bucket        = var.mlflow_artifact_bucket_name != "" ? var.mlflow_artifact_bucket_name : "${var.app_name}-artifacts-${random_pet.mlflow_artifacts.id}"
  force_destroy = true
  tags = {
    Name        = "${var.app_name}-artifacts"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_public_access_block" "mlflow_artifacts" {
  bucket                  = aws_s3_bucket.mlflow_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
