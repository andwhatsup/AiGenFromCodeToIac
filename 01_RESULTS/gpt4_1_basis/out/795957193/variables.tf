variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "zezf"
}

variable "instance_type" {
  description = "EC2 instance type for the application."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair to use for the EC2 instance."
  type        = string
}
