variable "s3_bucket" {
  default = "rockset-public"
}

variable "s3_key" {
  default = "iterator.zip"
}

variable "target_lambda" {
  description = "the ARN of the lambda to invoke"
}