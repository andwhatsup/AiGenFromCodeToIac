provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Define subnet within VPC
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "main-subnet"
  }
}

# Define EC2 instance for OpenVPN
resource "aws_instance" "openvpn_server" {
  ami = "ami-0c55b159cbfafe1f0"
  # To do -> Update to use free AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id

  tags = {
    Name = "OpenVPNServer"
  }
}

resource "aws_instance" "app_server" {
  ami = "ami-0c55b159cbfafe1f0"
  # To do -> Update to use free AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id

  tags = {
    Name = "AppServer"
  }
}

# S3 Bucket for storage (NFS alternative due to costs)
resource "aws_s3_bucket" "nfs_bucket" {
  bucket = "my-nfs-bucket"
}

resource "aws_s3_bucket_acl" "nfs_bucket_acl" {
  bucket = aws_s3_bucket.nfs_bucket.bucket
  acl    = "private"
}

# ECR Repository (only if Docker Hub is not preferred)
resource "aws_ecr_repository" "my_repository" {
  name = "my-repo"
}

resource "aws_kms_key" "my_key" {
  description             = "KMS key for encrypting data"
  deletion_window_in_days = 10
}

resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow all inbound traffic for OpenVPN and App Server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.app_sg.id
  network_interface_id = aws_instance.openvpn_server.primary_network_interface_id
}

resource "aws_network_interface_sg_attachment" "app_sg_attachment" {
  security_group_id    = aws_security_group.app_sg.id
  network_interface_id = aws_instance.app_server.primary_network_interface_id
}
