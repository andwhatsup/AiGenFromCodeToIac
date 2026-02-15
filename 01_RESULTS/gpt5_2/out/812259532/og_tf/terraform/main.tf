provider "aws" {
  region = "ap-south-1"
}

resource "aws_ecs_cluster" "helloWorld" {
  name = "helloWorld-cluster"
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Define the ECS task definition
resource "aws_ecs_task_definition" "helloWorld" {
  family                   = "hello-world"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "hello-world"
      image     = "851725266600.dkr.ecr.ap-south-1.amazonaws.com/hello-world-nodejs:latest" # Update this with your ECR repository URI
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

# Define the ECS service
resource "aws_ecs_service" "helloWorld" {
  name            = "helloWorld-service"
  cluster         = aws_ecs_cluster.helloWorld.id
  task_definition = aws_ecs_task_definition.helloWorld.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = ["subnet-005fc6c4dc01a48d3"]
    security_groups = ["sg-091a92188a1d830bc"]
  }
}
