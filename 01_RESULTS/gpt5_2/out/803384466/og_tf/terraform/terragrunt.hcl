# terragrunt.hcl
terraform {
  source = "./"
}

inputs = {
  region = "eu-central-1"  # Default value from variables.tf
  # Add other variables here if needed
}
