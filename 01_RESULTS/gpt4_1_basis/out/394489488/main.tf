resource "aws_s3_bucket" "mlflow_artifacts" {
  bucket        = var.mlflow_artifact_bucket != "" ? var.mlflow_artifact_bucket : "${var.app_name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-artifacts"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_ecr_repository" "mlflow" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true
  tags = {
    Name = var.app_name
  }
}

resource "aws_ecs_cluster" "mlflow" {
  name = "${var.app_name}-cluster"
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.app_name}-ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "mlflow" {
  name        = "${var.app_name}-sg"
  description = "Allow HTTP access to MLflow"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = var.mlflow_port
    to_port     = var.mlflow_port
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "mlflow" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mlflow.id]
  subnets            = data.aws_subnets.default.ids
  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_lb_target_group" "mlflow" {
  name     = "${var.app_name}-tg"
  port     = var.mlflow_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "${var.app_name}-tg"
  }
}

resource "aws_lb_listener" "mlflow" {
  load_balancer_arn = aws_lb.mlflow.arn
  port              = var.mlflow_port
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mlflow.arn
  }
}
