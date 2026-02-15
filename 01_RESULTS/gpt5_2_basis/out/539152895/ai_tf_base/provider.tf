provider "aws" {
  region = var.region

  default_tags {
    tags = {
      App       = var.app_name
      ManagedBy = "terraform"
    }
  }
}
