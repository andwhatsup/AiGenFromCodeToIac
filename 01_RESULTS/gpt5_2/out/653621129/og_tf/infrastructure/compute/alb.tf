resource "aws_lb" "hello_alb" {
  name               = "${var.name}-alb"
  internal           = false #tfsec:ignore:aws-elb-alb-not-public
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.vpc_public_subnets

  drop_invalid_header_fields = true

  tags = var.tags
}

resource "aws_lb_target_group" "hello_alb_tg" {
  name     = "${var.name}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
    matcher             = "200"
  }

  tags = var.tags
}

resource "aws_lb_listener" "hello_listener" {
  load_balancer_arn = aws_lb.hello_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.hello_alb_tg.arn
  }

  tags = var.tags
}