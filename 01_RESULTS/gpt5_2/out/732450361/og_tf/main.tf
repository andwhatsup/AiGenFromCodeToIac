
# This part is the EC2

provider "aws" {
  region = "us-east-2" # Replace with the appropriate region
}


resource "aws_instance" "api_server" {
  ami           = "ami-048e636f368eb3006" # Your selected AMI ID
  instance_type = "t2.micro"              # Choose an instance type that suits your needs



  tags = {
    Name = "API Server"
  }
}



#  This part is the VPC Portion with subnets
resource "aws_vpc" "Terraform_VPC_1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    name = "Terraform_VPC"
  }
}


# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.Terraform_VPC_1.id

  tags = {
    Name = "Terraform_VPC_IGW"
  }
}

# This part is the Subnets

# Private subnets
resource "aws_subnet" "Subnet1" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.Terraform_VPC_1.id
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "Subnet2" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.Terraform_VPC_1.id
  availability_zone = "us-east-2b"
}

# Public Subnets
resource "aws_subnet" "public_subnet1" {
  cidr_block              = "10.0.3.0/24"
  vpc_id                  = aws_vpc.Terraform_VPC_1.id
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform_Public_Subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  cidr_block              = "10.0.4.0/24"
  vpc_id                  = aws_vpc.Terraform_VPC_1.id
  availability_zone       = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "Terraform_Public_Subnet2"
  }
}

# Create a Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.Terraform_VPC_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Terraform_Public_RT"
  }
}

# Associate Public Subnet1 with Route Table
resource "aws_route_table_association" "public_rta1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Public Subnet2 with Route Table
resource "aws_route_table_association" "public_rta2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public_rt.id
}
