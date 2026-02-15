provider "aws" {
  region = "eu-west-1"
}

# Create an ECR repository
resource "aws_ecr_repository" "home_automation" {
  name = "home_automation"
}
