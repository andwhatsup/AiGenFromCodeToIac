data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_cluster" "react_jg_app" {
  name = "${var.app_name}-cluster"
  tags = {
    Name = "${var.app_name}-cluster"
  }
}

resource "aws_ecr_repository" "react_jg_app" {
  name = var.app_name
}

resource "aws_lb" "react_jg_app" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_lb_target_group" "react_jg_app" {
  name     = "${var.app_name}-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
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

resource "aws_lb_listener" "react_jg_app" {
  load_balancer_arn = aws_lb.react_jg_app.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.react_jg_app.arn
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.app_name}-ecs-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "react_jg_app" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = "${aws_ecr_repository.react_jg_app.repository_url}:latest"
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }]
      essential = true
    }
  ])
}

resource "aws_security_group" "react_jg_app" {
  name        = "${var.app_name}-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.app_name}-sg"
  }
}

resource "aws_ecs_service" "react_jg_app" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.react_jg_app.id
  task_definition = aws_ecs_task_definition.react_jg_app.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.react_jg_app.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.react_jg_app.arn
    container_name   = var.app_name
    container_port   = 3000
  }
  depends_on = [aws_lb_listener.react_jg_app]
  tags = {
    Name = var.app_name
  }
}
