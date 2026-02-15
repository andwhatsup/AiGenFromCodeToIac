provider "aws" {
  region = "ap-south-1" # Update with your desired AWS region
}


module "iam_resources" {
  source      = "./terraform/module"
  name_suffix = "devops"  ###give your suffix name 
}


