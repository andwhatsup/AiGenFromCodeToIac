provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Application = var.app_name
        ManagedBy   = "terraform"
      },
      var.tags
    )
  }
}
