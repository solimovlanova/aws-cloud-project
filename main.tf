data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "main" {
  count = var.use_default_vpc ? 1 : 0
  default = true
}

data "aws_subnets" "public" {
  count = var.use_default_vpc ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main[0].id]
  }
}

resource "random_string" "cloudtrail" {
  length  = 16
  upper   = false
  special = false
}

locals {
  default_vpc_id        = try(data.aws_vpc.main[0].id,"")
  custom_vpc_id         = aws_vpc.main[0].id 
  default_subnet_ids    = try(data.aws_subnets.public[0].ids,[])
  private_subnet_ids    = [aws_subnet.private_1[0].id, aws_subnet.private_2[0].id]
  public_subnet_ids     = [aws_subnet.public_1[0].id, aws_subnet.public_2[0].id]
  database_subnet_ids   = [aws_subnet.database_1[0].id, aws_subnet.database_2[0].id]
  private_subnet_cidrs  = [aws_subnet.private_1[0].cidr_block, aws_subnet.private_2[0].cidr_block]
  public_subnet_cidrs   = [aws_subnet.public_1[0].cidr_block, aws_subnet.public_2[0].cidr_block]
  database_subnet_cidrs = [aws_subnet.database_1[0].cidr_block, aws_subnet.database_2[0].cidr_block]
  vpc_id                = var.use_default_vpc ? data.aws_vpc.main[0].id : aws_vpc.main[0].id
  vpc_cidr              = var.use_default_vpc ? data.aws_vpc.main[0].cidr_block : aws_vpc.main[0].cidr_block
}


