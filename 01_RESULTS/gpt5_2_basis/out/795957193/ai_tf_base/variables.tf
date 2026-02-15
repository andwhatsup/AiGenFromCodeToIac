variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "Application name used for resource naming"
  type        = string
  default     = "terraform-deployment-app"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_key_name" {
  description = "Optional EC2 key pair name to enable SSH access"
  type        = string
  default     = null
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance (only used if ssh_key_name is set)"
  type        = string
  default     = "0.0.0.0/0"
}
