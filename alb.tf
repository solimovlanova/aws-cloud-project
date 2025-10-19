resource "aws_lb" "application" {
  count = var.create_alb ? 1 : 0
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = [data.aws_subnets.public.ids[0], data.aws_subnets.public.ids[1]]

  tags = {
    Environment = "production"
  }
}

resource "aws_security_group" "alb" {
  count = var.create_alb ? 1 : 0
  name        = "alb-sg"
  description = "Allow traffic to ALB"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "allow_tls"
  }
}


