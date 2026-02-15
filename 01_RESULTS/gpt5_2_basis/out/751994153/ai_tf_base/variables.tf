variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name used for tagging and resource naming."
  type        = string
  default     = "portfolio-website"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}

variable "ssh_ingress_cidr" {
  description = "CIDR allowed to SSH to the instance. Set to your IP/32."
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "Optional existing EC2 key pair name to attach for SSH access. If null, no key is attached."
  type        = string
  default     = null
}

variable "container_image" {
  description = "Container image to run on the EC2 host (e.g., from GitLab Container Registry)."
  type        = string
  default     = "nginx:latest"
}
