variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-northeast-1"
}

variable "app_name" {
  description = "Name prefix for resources."
  type        = string
  default     = "ec2-squid-proxy"
}

variable "allowed_cidr" {
  description = "Client CIDR allowed to use the Squid proxy (port 3128). Example: 203.0.113.10/32"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Optional existing EC2 key pair name for SSH access. If null, no key is attached."
  type        = string
  default     = null
}

variable "squid_port" {
  description = "Squid listening port."
  type        = number
  default     = 3128
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
