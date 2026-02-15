variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-northeast-1"
}

variable "app_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "ec2-squid-proxy"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to the instance (port 22). Set to your public IP/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "allowed_proxy_cidr" {
  description = "CIDR allowed to access Squid proxy (port 3128). Set to your public IP/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_pair_name" {
  description = "Optional existing EC2 key pair name to attach for SSH access. Leave null to not attach a key."
  type        = string
  default     = null
}

variable "squid_port" {
  description = "Squid proxy listening port"
  type        = number
  default     = 3128
}
