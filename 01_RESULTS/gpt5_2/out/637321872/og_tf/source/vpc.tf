# VPC
resource "aws_vpc" "my_net_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true # activate DNS hostname
  tags = {
    Name = "my-net-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "my_net_public_subnet" {
  vpc_id            = aws_vpc.my_net_vpc.id
  cidr_block        = var.pub_subnet_cidr
  availability_zone = var.az_a

  tags = {
    Name = "my-net-public-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "my_net_igw" {
  vpc_id = aws_vpc.my_net_vpc.id
  tags = {
    Name = "my-net-igw"
  }
}

# Route table
resource "aws_route_table" "my_net_public_rt" {
  vpc_id = aws_vpc.my_net_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_net_igw.id
  }
  tags = {
    Name = "my-net-public-rt"
  }
}

# associate route table with subnet
resource "aws_route_table_association" "my_net_public_rt_associate" {
  subnet_id      = aws_subnet.my_net_public_subnet.id
  route_table_id = aws_route_table.my_net_public_rt.id
}

# Security Group
# my home ip at now
data "http" "ifconfig" {
  url = "https://ipv4.icanhazip.com/"
}

variable "allowed_cidr" {
  default = null
}

locals {
  myip         = chomp(data.http.ifconfig.response_body)
  allowed_cidr = (var.allowed_cidr == null) ? "${local.myip}/32" : var.allowed_cidr
}

# Security Group
resource "aws_security_group" "my_net_ec2_sg" {
  name        = "my-net-ec2-sg"
  description = "for squid server"
  vpc_id      = aws_vpc.my_net_vpc.id
  tags = {
    Name = "my-net-ec2-sg"
  }

  # inbound rule
  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }
  # icmp
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [local.allowed_cidr]
  }
  # squid
  ingress {
    from_port   = 3128
    to_port     = 3128
    protocol    = "tcp"
    cidr_blocks = [local.allowed_cidr]
  }
  # outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}