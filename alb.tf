resource "aws_lb" "application" {
  count              = var.create_alb ? 1 : 0
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = var.use_default_vpc ? local.default_subnet_ids : local.public_subnet_ids

  tags = {
    Environment = "production"
  }
}

resource "aws_security_group" "alb" {
  count       = var.create_alb ? 1 : 0
  name        = "alb-sg"
  description = "Allow traffic to ALB"
  vpc_id      = local.vpc_id 


  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group_rule" "http-alb" {
  count             = var.create_alb ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [local.vpc_cidr]
  security_group_id = aws_security_group.alb[0].id
}

resource "aws_security_group_rule" "https-alb" {
  count             = var.create_alb ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [local.vpc_cidr]
  security_group_id = aws_security_group.alb[0].id
}

resource "aws_lb_target_group" "application_1" {
  count    = var.create_alb && var.create_app1 ? 1 : 0
  name     = "tg-application-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "front_end_app1" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.application[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_1[0].arn
  }
}







