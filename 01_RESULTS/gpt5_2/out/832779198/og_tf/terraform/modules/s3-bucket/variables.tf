variable "aws_region" {
  description = "value"
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "s3_bucket_lifecycle_days" {
  description = "The number of days the object is retained"
  default     = 7
  type        = number
}

variable "s3_bucket_force_destroy" {
  description = "The S3 bucket force destroy configuration"
  type        = bool
  default     = false
}

variable "iam_policy_name" {
  description = "The name of the IAM policy"
  type        = string
  default     = "policy"
}

variable "iam_group_name" {
  description = "The name of the IAM group"
  type        = string
  default     = "s3-group"
}

variable "iam_user_name" {
  description = "The name of the IAM user"
  type        = string
  default     = "s3-user"
}

variable "iam_role_name" {
  description = "The name of the IAM role"
  type        = string
  default     = "s3-role"
}

variable "iam_role_policy_name" {
  description = "The name of the IAM role policy"
  type        = string
  default     = "s3-role-policy"
}

variable "iam_assume_role_service" {
  description = "The AWS service that will assume the role"
  type        = string
  default     = "s3.amazonaws.com"
}

variable "prefix" {
  description = "Prefix to apply to resource names"
  type        = string
}

variable "suffix" {
  description = "Suffix to apply to resource names"
  type        = string
}
