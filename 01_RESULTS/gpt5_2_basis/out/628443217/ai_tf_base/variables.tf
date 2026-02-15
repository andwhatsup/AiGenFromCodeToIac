variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "ec2-test-server"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance. Set to your public IP/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to access HTTP (port 80)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_pair_name" {
  description = "Optional existing EC2 key pair name to enable SSH key-based login. If null, no key is attached."
  type        = string
  default     = null
}
