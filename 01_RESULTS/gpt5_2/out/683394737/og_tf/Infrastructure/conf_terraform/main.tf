terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "terraform-resources-test"
    key    = "tfstates"
    region = "us-east-1"
  }

}

provider "aws" {
  region = "us-east-1"

}

resource "aws_vpc" "demo-vpc" {

  cidr_block = "10.1.0.0/16"
  tags = {
    Name   = "Particular VPC"
    Author = "Mateo Matta"
  }
}

resource "aws_subnet" "demo-sub-01" {

  vpc_id                  = aws_vpc.demo-vpc.id
  cidr_block              = "10.1.0.0/16"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name   = "Particular subnet for us-east-1"
    Author = "Mateo Matta"
  }
}

resource "aws_internet_gateway" "ig-demo" {

  vpc_id = aws_vpc.demo-vpc.id

  tags = {
    Name   = "Principal Internet Gateway"
    Author = "Mateo Matta"
  }

}

resource "aws_route_table" "demo_route_table" {

  vpc_id = aws_vpc.demo-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig-demo.id
  }

  tags = {
    Name = "demo-rtb"
  }
}

resource "aws_route_table_association" "public1" {

  subnet_id      = aws_subnet.demo-sub-01.id
  route_table_id = aws_route_table.demo_route_table.id
}

resource "aws_security_group" "demo-sg-01" {

  name        = "allow_ssh_and_web_server_ports"
  description = "Allow SSH and web ports for inbound traffic"
  vpc_id      = aws_vpc.demo-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Web server port from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH connection from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }



  tags = {
    Name   = "allow_ssh_and_web_ports"
    Author = "Mateo Matta"
  }
}

resource "aws_autoscaling_group" "demo_autoscaling" {
  name                 = "demo-asg-instance-1"
  min_size             = "1"
  max_size             = "2"
  desired_capacity     = "2"
  vpc_zone_identifier  = [aws_subnet.demo-sub-01.id]
  launch_configuration = aws_launch_configuration.demo_configuration.name
  load_balancers       = [aws_elb.demo-elb.name]
  tag {
    key                 = "Name"
    value               = "demo-asg-instance-1"
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "demo_configuration" {
  lifecycle {
    create_before_destroy = true
  }

  name                        = "placeholder-demo-lc"
  image_id                    = "ami-0261755bbcb8c4a84"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.demo-sg-01.id]
  associate_public_ip_address = true
  key_name                    = "candidate"
  user_data                   = file("../scripts/ansibleLaunchConfiguration.sh")

}

resource "aws_elb" "demo-elb" {

  name            = "demo-elb-elbb"
  subnets         = [aws_subnet.demo-sub-01.id]
  security_groups = [aws_security_group.demo-sg-01.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 29
  }

}


resource "aws_s3_bucket" "s3Bucket" {
  bucket = "terraform-resources-test"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3Bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["729158664723"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.s3Bucket.arn,
      "${aws_s3_bucket.s3Bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_versioning" "versioning_for_s3Bucket" {
  bucket = aws_s3_bucket.s3Bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# resource "random_password" "password" {
#   length           = 16
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# module "rds_example_complete-mysql" {
#   source  = "terraform-aws-modules/rds/aws//examples/complete-mysql"
#   version = "6.1.1"
# }


#create a security group for RDS Database Instance
# resource "aws_security_group" "rds_sg" {
#   name = "rds_sg"

#   Allow private connection from subnet inside the VPC that contains EC2 machines that have Docker containers running, to access the RDS MySQL database created.

#   ingress {
#     from_port       = 3306
#     to_port         = 3306
#     protocol        = "tcp"
#     cidr_blocks = ["172.xxx.xxx.xxx/32"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# #create a RDS Database Instance
# resource "aws_db_instance" "myinstance" {
#   engine               = "mysql"
#   identifier           = "myrdsinstance"
#   allocated_storage    =  20
#   engine_version       = "8.0.33"
#   instance_class       = "db.t3.micro"
#   username             = "myrdsuser"
#   password             = "test-password123"
#   parameter_group_name = "default.mysql5.7"
#   vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
#   skip_final_snapshot  = true
#   publicly_accessible =  true
# }

