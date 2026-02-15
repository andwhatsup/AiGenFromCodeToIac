# Minimal baseline infrastructure inferred from repo:
# - Node.js project with Dockerfile and docker-compose referencing an ECR image.
# - No clear long-running web server entrypoint; primarily used for CI tests.
#
# To keep deployment minimal and broadly compatible, we provision:
# - An ECR repository to store the built image.
# - (Optional) a CloudWatch Log Group for future ECS tasks.

resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/${var.app_name}"
  retention_in_days = 14
}
