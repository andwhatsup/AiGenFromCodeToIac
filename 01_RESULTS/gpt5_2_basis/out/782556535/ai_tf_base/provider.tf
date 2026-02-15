provider "aws" {
  region                      = var.aws_region
  access_key                  = var.aws_access_key
  secret_key                  = var.aws_secret_key
  skip_credentials_validation = var.aws_skip_credentials_validation
  skip_metadata_api_check     = var.aws_skip_metadata_api_check
  skip_requesting_account_id  = var.aws_skip_requesting_account_id

  s3_use_path_style = var.aws_s3_use_path_style

  endpoints {
    s3  = var.aws_endpoint_url
    iam = var.aws_endpoint_url
    sts = var.aws_endpoint_url
  }

  default_tags {
    tags = {
      Project = var.app_name
      Managed = "terraform"
    }
  }
}
