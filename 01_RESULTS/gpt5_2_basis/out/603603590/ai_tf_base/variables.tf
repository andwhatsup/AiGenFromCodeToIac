variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for naming/tagging"
  type        = string
  default     = "test-kafka"
}

variable "instance_type" {
  description = "EC2 instance type for the single-node docker host"
  type        = string
  default     = "t3.small"
}

variable "ssh_public_key" {
  description = "SSH public key material to access the instance"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance"
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_ui_cidr" {
  description = "CIDR allowed to access HTTP/HTTPS and Kafka UI"
  type        = string
  default     = "0.0.0.0/0"
}
