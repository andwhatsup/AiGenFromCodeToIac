terraform {
  required_version = ">= 0.13"
}
provider "aws" {
  region                   = "ap-south-1"
  shared_credentials_files = ["C:\\Users\\10729794\\.aws\\credentials"]
}

resource "aws_security_group" "lb" {
  name   = "example-alb-security-group"
  vpc_id = "vpc-0ece565c65e0f14bd"

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "default" {
  name            = "example-lb"
  subnets         = ["subnet-0c7242d57050472a5", "subnet-0ec1d54511102fa93"]
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "hello_world" {
  name        = "example-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "vpc-0ece565c65e0f14bd"
  target_type = "ip"
}

resource "aws_lb_listener" "hello_world" {
  load_balancer_arn = aws_lb.default.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.hello_world.id
    type             = "forward"
  }
}

resource "aws_ecs_task_definition" "hello_world" {
  family                   = "hello-world-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = "arn:aws:iam::433375820816:role/ecr"

  container_definitions = <<DEFINITION
[
  {
    "image": "433375820816.dkr.ecr.ap-south-1.amazonaws.com/nodeapp:img-test-lambda",
    "cpu": 1024,
    "memory": 1024,
    "name": "hello-world-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ]
  }
]
DEFINITION
}

resource "aws_security_group" "hello_world_task" {
  name   = "example-task-security-group"
  vpc_id = "vpc-0ece565c65e0f14bd"

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 8080
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "main" {
  name = "example-cluster"
}

resource "aws_ecs_service" "hello_world" {
  name            = "hello-world-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.hello_world.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.hello_world_task.id]
    subnets         = ["subnet-0c7242d57050472a5"]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_world.id
    container_name   = "hello-world-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.hello_world]
}
