variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "test-kafka"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ssh_public_key" {
  description = "SSH public key material to access the instance"
  type        = string
  default     = null
}

variable "ssh_public_key_path" {
  description = "Path to an SSH public key file (used if ssh_public_key is null)"
  type        = string
  default     = "../ssh/test-kafka-do.pub"
}
