variable "app_name" {
  description = "Name of the application."
  type        = string
  default     = "portfolio-website"
}

variable "instance_type" {
  description = "EC2 instance type for the application."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for EC2."
  type        = string
  default     = ""
}

variable "subnet_az" {
  description = "The availability zone to select the subnet from."
  type        = string
  default     = "us-east-1a"
}
