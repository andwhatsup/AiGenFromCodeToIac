variable "security_groups" {
  description = "The VPC security groups to use"
  type        = list(string)
}

variable "subnets" {
  description = "The VPC subnets to use"
  type        = list(string)
}

variable "execution_role_arn" {
  description = "The execution role ARN to use"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "MONGODB_URI" {
  description = "MongoDB Atlas URI"
  type        = string
}
