provider "aws" {
  region                      = var.region
  access_key                  = var.aws_access_key_id
  secret_key                  = var.aws_secret_access_key
  skip_credentials_validation = var.skip_credentials_validation
  skip_metadata_api_check     = var.skip_metadata_api_check
  skip_requesting_account_id  = var.skip_requesting_account_id

  s3_use_path_style = var.s3_use_path_style

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
