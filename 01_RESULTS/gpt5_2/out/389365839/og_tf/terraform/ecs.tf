resource "aws_security_group" "task_sg" {
  name   = "ecs-security-group"
  vpc_id = aws_vpc.ecs_vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.ecs_alb_sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "ecs_task-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecution_role" {
  name               = "ecsTaskExecution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task-assume-role-policy.json
}

resource "aws_iam_role_policy" "ecsTaskExecution_policy" {
  name = "ecsTaskExecPolicy"
  role = aws_iam_role.ecsTaskExecution_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "poc-cluster"
}

resource "aws_ecs_task_definition" "taskdef" {
  family       = "mehlj-pipeline"
  network_mode = "awsvpc"

  # EC2 backing vs fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  # Summary: Execution Roles grant the ECS agents permission to make AWS API calls.
  # I.e.: The task is able to send container logs to CloudWatch or pull an image from ECR.
  # -----
  # allows ECS agent to pull image from ECR
  execution_role_arn = aws_iam_role.ecsTaskExecution_role.arn

  container_definitions = jsonencode([
    {
      name      = "mehlj-pipeline"
      image     = var.image_tag
      cpu       = 1024
      memory    = 2048
      essential = true
      environment = [
        {
          name  = "PG_DSN"
          value = var.pg_dsn
        }
      ]
      network_mode = "awsvpc"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      # needs IAM as well
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "ecs-poc"
          awslogs-region        = "us-east-1"
          awslogs-create-group  = "true"
          awslogs-stream-prefix = "mehlj-pipeline"
        }
      }
    },
  ])
}

resource "aws_ecs_service" "service" {
  name            = "mehlj-pipeline"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.taskdef.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.task_sg.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.asg-tg.arn
    container_name   = "mehlj-pipeline"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.ecs-lb-list]
}