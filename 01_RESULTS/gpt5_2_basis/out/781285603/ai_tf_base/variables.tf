variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Base name used for created resources."
  type        = string
  default     = "energi-node"
}

variable "name_suffix" {
  description = "Optional suffix appended to IAM entity names (e.g., 'prod', 'ci')."
  type        = string
  default     = ""
}
