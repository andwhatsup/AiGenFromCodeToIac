variable "instance_type" {
  description = "EC2 instance type for Squid proxy."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the EC2 Key Pair to allow SSH access."
  type        = string
}

variable "allowed_ip" {
  description = "The IP address allowed to access the Squid proxy (format: x.x.x.x/32)."
  type        = string
}
