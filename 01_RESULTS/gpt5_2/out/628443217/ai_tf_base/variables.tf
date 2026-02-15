variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-northeast-1"
}

variable "app_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "ec2-test-server"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH to the instance (set to your public IP/32)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "http_ingress_cidr" {
  description = "CIDR allowed to access HTTP (nginx)"
  type        = string
  default     = "0.0.0.0/0"
}
