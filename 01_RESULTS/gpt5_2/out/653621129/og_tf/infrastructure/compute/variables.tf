variable "name" {
  type        = string
  description = "Name to apply to resources"
  default     = "franklin"
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to created resources."
  default     = {}
}

variable "vpc" {
  type        = string
  description = "VPC ID for the VPC this compute is running in"
  nullable    = false
}

variable "vpc_public_subnets" {
  type        = list(any)
  description = "Public subnets for the VPC the compute is running in"
  nullable    = false
}

variable "vpc_private_subnets" {
  type        = list(any)
  description = "Private subnets for the VPC the compute is running in"
  nullable    = false
}

variable "image_name" {
  type        = string
  description = "Docker respository + tag used as task"
  default     = "obbiearms/hello-world:latest"
}

variable "min_count" {
  type        = number
  description = "Minimum container count for hello world service"
  default     = 1
}

variable "desired_count" {
  type        = number
  description = "Desired container count for hello world service"
  default     = 1
}

variable "max_count" {
  type        = number
  description = "Max container count for hello world service"
  default     = 5
}

variable "min_ec2_count" {
  type        = number
  description = "Minimum EC2 count for hello world ASG"
  default     = 1
}

variable "desired_ec2_count" {
  type        = number
  description = "Desired EC2 count for hello world ASG"
  default     = 1
}

variable "max_ec2_count" {
  type        = number
  description = "Max EC2 count for hello world ASG"
  default     = 3
}