# availability_zone
variable "az_a" {
  default = "ap-northeast-1a"
}

# vpc cidr_block
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

# public subnet cidr_block
variable "pub_subnet_cidr" {
  default = "10.0.1.0/24"
}
