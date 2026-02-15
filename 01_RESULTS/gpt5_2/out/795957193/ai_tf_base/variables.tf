variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "zezf"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Optional existing EC2 Key Pair name to enable SSH access. Leave null to disable SSH ingress."
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH when ssh_key_name is set."
  type        = string
  default     = "0.0.0.0/0"
}
