# module "ec2-instance" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "5.8.0"
#   ami = "ami-01f23391a59163da9"
#   instance_type = "t2.micro"
#   vpc_security_group_ids = []
#   user_data = <<-EOF
#               #!/bin/bash
#               sudo apt-get update -y
#               sudo snap install amazon-ssm-agent --classic

#               # Enable and start the agent
#               sudo systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent.service
#               sudo systemctl start snap.amazon-ssm-agent.amazon-ssm-agent.service
#               EOF

           
# }

# resource "aws_iam_instance_profile" "dev_profile" {
#   name = "test_profile"
#   role = aws_iam_role.role.name
# }

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#     actions = ["sts:AssumeRole"]
#   }
# }

# resource "aws_iam_role" "role" {
#   name               = "test_role"
#   path               = "/"
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

