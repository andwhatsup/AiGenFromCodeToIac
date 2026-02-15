resource "aws_ecs_cluster" "minecraft" {
  name = "${var.app_name}-cluster"
  tags = {
    Name = "${var.app_name}-cluster"
  }
}

resource "aws_ecr_repository" "minecraft" {
  name                 = "${var.app_name}-ecr"
  image_tag_mutability = "MUTABLE"
  tags = {
    Name = "${var.app_name}-ecr"
  }
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

resource "aws_security_group" "minecraft_sg" {
  name        = "${var.app_name}-sg"
  description = "Allow Minecraft and RCON ports"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 25565
    to_port     = 25575
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 4326
    to_port     = 4327
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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_task_definition" "minecraft" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      name  = "lobby"
      image = aws_ecr_repository.minecraft.repository_url
      portMappings = [
        { containerPort = 25565, hostPort = 25565, protocol = "tcp" },
        { containerPort = 25575, hostPort = 25575, protocol = "tcp" },
        { containerPort = 4326, hostPort = 4326, protocol = "tcp" },
        { containerPort = 4327, hostPort = 4327, protocol = "tcp" }
      ]
      environment = [
        { name = "MOTD", value = "Vanilla Minecraft, Chill Vibes Only" },
        { name = "EULA", value = "TRUE" },
        { name = "RCON_PASSWORD", value = "Test" },
        { name = "TYPE", value = "PAPER" },
        { name = "VERSION", value = "1.19.2" },
        { name = "MEMORY", value = "2G" }
      ]
      essential = true
    }
  ])
  tags = {
    Name = "${var.app_name}-task"
  }
}

resource "aws_ecs_service" "minecraft_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.minecraft.id
  task_definition = aws_ecs_task_definition.minecraft.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.minecraft_sg.id]
    assign_public_ip = true
  }
  tags = {
    Name = "${var.app_name}-service"
  }
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_policy]
}
