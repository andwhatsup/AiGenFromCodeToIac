resource "aws_ecs_task_definition" "hello_world" {
  family = "${var.name}-hello-world"

  container_definitions = jsonencode([
    {
      "name" : "hello-world",
      "cpu" : 16,
      "memory" : 128,
      "image" : "${var.image_name}",
      "essential" : true,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 0
        }
      ],
      "healthCheck" : {
        "command" : [
          "CMD-SHELL",
          "curl -f http://localhost/ || exit 1"
        ],
        "interval" : 30
      }
    }
  ])
  execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn

  tags = var.tags
}


# Service to run task permenantly and provide
# link to ALB target group
resource "aws_ecs_service" "hello_world_service" {
  name            = "${var.name}-ecs-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.hello_world.arn
  desired_count   = var.desired_count

  load_balancer {
    target_group_arn = aws_lb_target_group.hello_alb_tg.arn
    container_name   = "hello-world"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = var.tags
}

resource "aws_ecs_cluster" "ecs" {
  name = "${var.name}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

# Capacity providers
# Currently single provider for our ASG
resource "aws_ecs_capacity_provider" "ecs_ec2_capacity_provider" {
  name = "${var.name}-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_capacity" {
  cluster_name = aws_ecs_cluster.ecs.name

  capacity_providers = [aws_ecs_capacity_provider.ecs_ec2_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_ec2_capacity_provider.name
  }
}

