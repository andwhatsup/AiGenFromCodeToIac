variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile name to use. Set to null to use environment credentials."
  type        = string
  default     = null
}

variable "app_name" {
  description = "Application name used for resource naming."
  type        = string
  default     = "ontwikkelingsbedrywighede"
}

variable "tags" {
  description = "Tags applied to all supported resources."
  type        = map(string)
  default = {
    Project = "ontwikkelingsbedrywighede"
    Managed = "terraform"
  }
}

variable "lambda_zip_path" {
  description = "Path to the pre-built Lambda zip artifact (relative to this Terraform root)."
  type        = string
  default     = "../lambda.zip"
}
