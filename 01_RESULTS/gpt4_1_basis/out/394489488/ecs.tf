resource "aws_ecs_task_definition" "mlflow" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name  = var.app_name
      image = aws_ecr_repository.mlflow.repository_url
      portMappings = [{
        containerPort = var.mlflow_port
        hostPort      = var.mlflow_port
        protocol      = "tcp"
      }]
      environment = [
        { name = "PORT", value = tostring(var.mlflow_port) },
        { name = "MLFLOW_ARTIFACT_URI", value = "s3://${aws_s3_bucket.mlflow_artifacts.bucket}/" }
      ]
      essential = true
    }
  ])
  tags = {
    Name = var.app_name
  }
}

resource "aws_ecs_service" "mlflow" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.mlflow.id
  task_definition = aws_ecs_task_definition.mlflow.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.mlflow.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.mlflow.arn
    container_name   = var.app_name
    container_port   = var.mlflow_port
  }
  depends_on = [aws_lb_listener.mlflow]
  tags = {
    Name = var.app_name
  }
}
