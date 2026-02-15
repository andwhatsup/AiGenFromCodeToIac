# IAM for the EC2 Auto Scaling Group Instances
# Use standard AWS provided service role

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "asg_iam_role" {
  name               = "${var.name}-asg-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  tags = var.tags
}

resource "aws_iam_policy_attachment" "ecs_ec2_attachment" {
  name       = "${var.name}-asg-ec2-ecs-attachment"
  roles      = [aws_iam_role.asg_iam_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}