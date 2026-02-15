
data "aws_ami" "asg_ami" {
  # AWS verified ECS images
  owners      = ["591542846629"]
  most_recent = true
  name_regex  = "amzn2-ami-ecs-hvm.+x86_64.+"
}

resource "aws_launch_template" "asg_launch_template" {
  name_prefix   = var.name
  image_id      = data.aws_ami.asg_ami.id
  instance_type = "t3a.micro"
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.asg_iam_instance_profile.name
  }

  metadata_options {
    http_tokens = "required"
  }

  user_data = base64encode("#!/bin/sh\necho ECS_CLUSTER=${aws_ecs_cluster.ecs.name} >> /etc/ecs/ecs.config")

  tags = var.tags
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = var.desired_ec2_count
  max_size         = var.max_ec2_count
  min_size         = var.min_ec2_count

  launch_template {
    id      = aws_launch_template.asg_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = var.vpc_private_subnets
}

resource "aws_iam_instance_profile" "asg_iam_instance_profile" {
  name = "${var.name}-asg-instance-profile"
  role = aws_iam_role.asg_iam_role.name
}