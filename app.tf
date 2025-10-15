
resource "aws_instance" "application_1" {
 ami = "ami-0c55b159cbfafe1f0"
 instance_type = "t2.micro"
 tags = {
   Name = "Application_1"
 }
}

