# only allow port 80 to load balancer
# allow all egress traffic out
resource "aws_security_group" "ecs_alb_sg" {
  name   = "ecs_alb_sg"
  vpc_id = aws_vpc.ecs_vpc.id

  ingress {
    description = "HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "ecs-lb" {
  name            = "ecs-lb"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.ecs_alb_sg.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "asg-tg" {
  name        = "asg-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_vpc.id
  target_type = "ip"
}

resource "aws_lb_listener" "ecs-lb-list" {
  load_balancer_arn = aws_lb.ecs-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg-tg.arn
  }
}

output "alb_domain_name" {
  value = aws_lb.ecs-lb.dns_name
}