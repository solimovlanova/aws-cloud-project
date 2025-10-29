
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "application_1" {
  count                  = var.create_app1 ? 1 : 0
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app1[0].id] 
  subnet_id              = var.use_default_vpc ? local.default_subnet_ids[0] : local.private_subnet_ids[0]
  lifecycle {
    ignore_changes = [ami]
  }
  tags = {
    Name = "Application_1"
  }
}


resource "aws_lb_target_group_attachment" "application_1" {
  count            = var.create_app1 && var.create_alb ? 1 : 0
  target_group_arn = aws_lb_target_group.application_1[0].arn
  target_id        = aws_instance.application_1[0].id
  port             = 80
}


resource "aws_security_group" "app1" {
  count       = var.create_app1 ? 1 : 0
  name        = "ec2-sg"
  description = "Allow traffic to EC2"
  vpc_id      = local.vpc_id

  tags = {
    Name = "app1-sg"
  }
}

resource "aws_security_group_rule" "http-alb-ec2" {
  count                    = var.create_alb  && var.create_app1 ? 1 : 0 
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app1[0].id
  source_security_group_id = aws_security_group.alb[0].id
}


resource "aws_security_group_rule" "https-alb-ec2" {
  count                    = var.create_alb && var.create_app1 ? 1 : 0
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app1[0].id
  source_security_group_id = aws_security_group.alb[0].id
}

