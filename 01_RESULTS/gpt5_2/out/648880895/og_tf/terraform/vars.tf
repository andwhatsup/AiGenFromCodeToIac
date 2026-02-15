variable "iam_role" {
  default     = "arn:aws:iam::995819606325:role/boto3aws_workshop"
  description = "value"
  type        = string

}

variable "az" {
  default     = "us-east-1a"
  description = "AVailability zone"
  type        = string
}
variable "botos3_workshop" {
  type    = string
  default = "value"
}
variable "vpc-cidr" {
  default     = "10.0.0.0/16"
  description = "VPC CIDR BLOCK"
  type        = string
}
variable "public_pubnet_1" {
  default     = "10.0.0.0/24"
  description = "Public_Subnet_1"
  type        = string
}
variable "private_pubnet_1" {
  default     = "10.0.2.0/24"
  description = "Private_Subnet_1"
  type        = string
}
variable "ssh-location" {
  default     = "0.0.0.0/0"
  description = "SSH variable for bastion host"
  type        = string
}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
variable "key_name" {
  default = "boto3-workshop"
  type    = string
}