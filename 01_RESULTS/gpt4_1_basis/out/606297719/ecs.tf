resource "aws_ecs_cluster" "prefect_agent" {
  name = var.ecs_agent_name
}

resource "aws_ecs_task_definition" "prefect_agent" {
  family                   = var.ecs_agent_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name      = "prefect-agent"
      image     = "prefecthq/prefect:2.7.11-python3.9"
      essential = true
      environment = [
        { name = "PREFECT_API_KEY", value = var.prefect_api_key },
        { name = "PREFECT_API_URL", value = "https://api.prefect.cloud/api/accounts/${var.prefect_account_id}/workspaces/${var.prefect_workspace_id}" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.ecs_agent_name}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "prefect_agent" {
  name            = var.ecs_agent_name
  cluster         = aws_ecs_cluster.prefect_agent.id
  task_definition = aws_ecs_task_definition.prefect_agent.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.agent_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_service.id]
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_policy]
}

resource "aws_security_group" "ecs_service" {
  name        = "ecs-service-sg"
  description = "Allow all egress"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "ecs_agent" {
  name              = "/ecs/${var.ecs_agent_name}"
  retention_in_days = 7
}
