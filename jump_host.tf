data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "jump_host" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.jump_host.id]

  subnet_id = var.subnet_id
  tags = {
    Name = "jump_host"
  }
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_key_pair" "jump_host_key" {
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDaK57S/8BRnvr+u33RlU6nXKP5Cxdz36Bl5bFWU05qD"
  #this is not for production, not any security practice violated.

}

resource "aws_security_group" "jump_host" {
  name        = "jumphost_sg"
  description = "security group for jump host"

}

resource "aws_security_group_rule" "allow_all_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.jump_host.id
}

