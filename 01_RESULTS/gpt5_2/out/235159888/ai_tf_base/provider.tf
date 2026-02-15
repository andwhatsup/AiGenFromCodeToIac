provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        ManagedBy = "Terraform"
        Project   = var.app_name
      },
      var.tags
    )
  }
}
