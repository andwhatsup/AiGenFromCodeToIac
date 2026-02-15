# Configure the Terraform backend to use an S3 bucket
terraform {

  required_providers {
    aws = {
      version = ">= 5.39.0"
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "pixelpredict"
    key    = "terraform/state/main.tfstate"
    region = "us-west-1"
  }
}

# Define the provider
provider "aws" {
  region = "us-west-1"
}

# Create an IAM role
resource "aws_iam_role" "pixelpredict-stream-reader-role" {
  name = "pixelpredict-stream-reader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })


  tags = {
    createdBy     = "terraform"
    createdFor    = "tf-migrate bug bash"
    terraformTime = "${timestamp()}"
    CanDelete     = "true"
  }
}

# Attach a policy to the IAM role
resource "aws_iam_role_policy_attachment" "example_policy_attachment" {
  role       = aws_iam_role.pixelpredict-stream-reader-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Output the role ARN
output "role_arn" {
  value = aws_iam_role.pixelpredict-stream-reader-role.arn
}
