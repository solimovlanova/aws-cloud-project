
resource "aws_instance" "application_1" {
 count = var.create_app1 ? 1 : 0
 ami = "ami-033a3fad07a25c231"
 instance_type = "t2.micro"
 subnet_id = data.aws_subnets.public.ids[0]
 tags = {
   Name = "Application_1"
 }
}


