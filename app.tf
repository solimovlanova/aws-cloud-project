
resource "aws_instance" "application_1" {
 count = var.create_app1 ? 1 : 0
 ami = "ami-033a3fad07a25c231"
 instance_type = "t2.micro"
 security_groups = [aws_security_group.app1[0].name]
 subnet_id = data.aws_subnets.public.ids[0]
 tags = {
   Name = "Application_1"
 }
}


resource "aws_lb_target_group_attachment" "application_1" {
  count            = var.create_app1 ? 1 : 0
  target_group_arn = aws_lb_target_group.application_1.arn
  target_id        = aws_instance.application_1[0].id
  port             = 80
}


resource "aws_security_group" "app1" {
  count = var.create_alb ? 1 : 0
  name        = "ec2-sg"
  description = "Allow traffic to EC2"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "app1-sg"
  }
}

resource "aws_security_group_rule" "http-alb-ec2" {
  count = var.create_alb ? 1 : 0
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.app1[0].id 
  source_security_group_id = aws_security_group.alb[0].id
}


resource "aws_security_group_rule" "https-alb-ec2" {
  count = var.create_alb ? 1 : 0
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.app1[0].id 
  source_security_group_id = aws_security_group.alb[0].id
}

