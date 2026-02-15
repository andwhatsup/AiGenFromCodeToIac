
locals {
  public_cidr = "0.0.0.0/0"
}

# Security group for ALB
# Allow HTTP and HTTPS (HTTPS not implemented however) ingress
# All outbound egress
resource "aws_security_group" "alb_sg" {
  name        = "${var.name}-alb-sg"
  description = "Control access to the public facing ALB"
  vpc_id      = var.vpc

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "http_ingress" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTP traffic ingress"

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = local.public_cidr
}

resource "aws_vpc_security_group_ingress_rule" "https_ingress" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow HTTPS traffic ingress"

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = local.public_cidr
}

resource "aws_vpc_security_group_egress_rule" "all_egress" {
  security_group_id = aws_security_group.alb_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = local.public_cidr
}


# Security Group for EC2 instances in the ASG
# since our ECS containers will use a bridge network
# the actual port that the ALB will connect to
# will not be fixed, so we allow traffic
# on all ports only from the ALB sg
resource "aws_security_group" "ec2_sg" {
  name        = "${var.name}-ecs-sg"
  description = "Control access for EC2s in ECS cluster"

  vpc_id = var.vpc

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "ec2_all_egress" {
  security_group_id = aws_security_group.ec2_sg.id
  description       = "Allow all egress"

  ip_protocol = "-1"
  cidr_ipv4   = local.public_cidr
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress_to_ec2" {
  security_group_id = aws_security_group.ec2_sg.id
  description       = "Allow all ingress traffic from ALB Security Group"

  referenced_security_group_id = aws_security_group.alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 1
  to_port                      = 65535



}