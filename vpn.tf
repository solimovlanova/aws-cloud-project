# Security Group for VPN Server
resource "aws_security_group" "vpn_sg" {
  count       = var.create_vpn_server ? 1 : 0
  name        = "vpn-server-sg"
  description = "Security group for OpenVPN server"
  vpc_id      = aws_vpc.main[0].id

  # OpenVPN UDP
  ingress {
    description = "OpenVPN UDP"
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # OpenVPN TCP (alternative)
  ingress {
    description = "OpenVPN TCP"
    from_port   = 1194
    to_port     = 1194
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic (required for SSM and internet access)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpn-server-sg"
  }
}

# IAM Role for VPN Server (SSM access)
resource "aws_iam_role" "vpn_server_role" {
  count = var.create_vpn_server ? 1 : 0
  name  = "vpn-server-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "vpn-server-role"
  }
}

# Attach SSM managed policy to the role
resource "aws_iam_role_policy_attachment" "vpn_server_ssm" {
  count      = var.create_vpn_server ? 1 : 0
  role       = aws_iam_role.vpn_server_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "vpn_server_profile" {
  count = var.create_vpn_server ? 1 : 0
  name  = "vpn-server-profile"
  role  = aws_iam_role.vpn_server_role[0].name
}

# VPN Server EC2 Instance
resource "aws_instance" "vpn_server" {
  count                       = var.create_vpn_server ? 1 : 0
  ami                         = data.aws_ami.ubuntu_vpn[0].id
  instance_type               = "t3.micro"
  subnet_id                   = var.use_default_vpc ? local.default_subnet_ids[0] : aws_subnet.public_1[0].id
  vpc_security_group_ids      = [aws_security_group.vpn_sg[0].id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.vpn_server_profile[0].name

  user_data = <<-EOF
              #!/bin/bash
              # Install SSM Agent
              sudo snap install amazon-ssm-agent --classic
              sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
              sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
              
              # Download OpenVPN installation script
              curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
              chmod +x openvpn-install.sh
              EOF

  tags = {
    Name = "openvpn-server"
  }
}

# Data source to get the latest Ubuntu AMI for VPN
data "aws_ami" "ubuntu_vpn" {
  count       = var.create_vpn_server ? 1 : 0
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
