resource "aws_ecs_cluster" "cluster" {
  name = "carlos-ecs-cluster"
  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "capacity_provider" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_cloudwatch_log_group" "mongodb_aws_ecs" {
  name              = "mongodb_aws_ecs"
  retention_in_days = 1

  tags = local.tags
}

resource "aws_ecs_task_definition" "mongodb_aws_ecs" {
  container_definitions = jsonencode(
    [
      {
        cpu = 0
        environment = [
          { name : "MONGODB_URI", value : var.MONGODB_URI }
        ]
        environmentFiles = []
        essential        = true
        image            = var.container_image
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "mongodb_aws_ecs"
            awslogs-region        = local.aws_region
            awslogs-stream-prefix = "ecs"
          }
        }
        mountPoints  = []
        name         = "mongodb_aws_ecs"
        portMappings = []
        volumesFrom  = []
      },
    ]
  )
  cpu                = "1024"
  execution_role_arn = var.execution_role_arn
  task_role_arn      = var.execution_role_arn
  family             = "mongodb_aws_ecs"
  memory             = "3072"
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE",
  ]
  tags     = {}
  tags_all = {}

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_service" "mongodb_aws_ecs" {
  cluster                            = aws_ecs_cluster.cluster.arn
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  desired_count                      = 1
  enable_ecs_managed_tags            = true
  enable_execute_command             = false
  health_check_grace_period_seconds  = 0
  name                               = "mongodb_aws_ecs"
  platform_version                   = "LATEST"
  propagate_tags                     = "NONE"
  scheduling_strategy                = "REPLICA"
  tags                               = {}
  tags_all                           = {}
  task_definition                    = aws_ecs_task_definition.mongodb_aws_ecs.arn
  triggers                           = {}

  capacity_provider_strategy {
    base              = 1
    capacity_provider = "FARGATE"
    weight            = 100
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = true
    security_groups  = var.security_groups
    subnets          = var.subnets
  }

  timeouts {}
}
