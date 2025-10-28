# VPC
resource "aws_vpc" "main" {
  count = var.create_custom_vpc ? 1 : 0
  cidr_block = "172.16.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# IG
resource "aws_internet_gateway" "main" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id
  tags = {
    Name = "main-gw"
  }
}

# EIP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.create_custom_vpc ? 1 : 0
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
  depends_on = [aws_internet_gateway.main[0]]
}

# NAT Gateway (shared by all private subnets)
resource "aws_nat_gateway" "main" {
  count = var.create_custom_vpc ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_1[0].id
  tags = {
    Name = "main-nat-gw"
  }
  depends_on = [aws_internet_gateway.main[0]]
}

# SUBNETS

resource "aws_subnet" "private_1" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id     = aws_vpc.main[0].id
  cidr_block = "172.16.1.0/24"

  tags = {
    Name = "main-vpc-subnet-private-1"
  }
}

resource "aws_subnet" "private_2" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id     = aws_vpc.main[0].id
  cidr_block = "172.16.2.0/24"

  tags = {
    Name = "main-vpc-subnet-private-2"
  }
}

resource "aws_subnet" "public_1" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id     = aws_vpc.main[0].id
  cidr_block = "172.16.3.0/24"

  tags = {
    Name = "main-vpc-subnet-public-1"
  }
}

resource "aws_subnet" "public_2" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id     = aws_vpc.main[0].id
  cidr_block = "172.16.4.0/24"

  tags = {
    Name = "main-vpc-subnet-public-2"
  }
}

resource "aws_subnet" "database_1" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id     = aws_vpc.main[0].id
  cidr_block = "172.16.5.0/24"

  tags = {
    Name = "main-vpc-subnet-database-1"
  }
}

resource "aws_subnet" "database_2" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id     = aws_vpc.main[0].id
  cidr_block = "172.16.6.0/24"

  tags = {
    Name = "main-vpc-subnet-database-2"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Private Route Table (shared by all private subnets)
resource "aws_route_table" "private" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Database Route Table (isolated, no internet access)
resource "aws_route_table" "database" {
  count = var.create_custom_vpc ? 1 : 0
  vpc_id = aws_vpc.main[0].id

  tags = {
    Name = "database-route-table"
  }
}

# Route Table Associations - Public Subnets
resource "aws_route_table_association" "public_1" {
  count = var.create_custom_vpc ? 1 : 0
  subnet_id      = aws_subnet.public_1[0].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "public_2" {
  count = var.create_custom_vpc ? 1 : 0
  subnet_id      = aws_subnet.public_2[0].id
  route_table_id = aws_route_table.public[0].id
}

# Route Table Associations - Private Subnets
resource "aws_route_table_association" "private_1" {
  count = var.create_custom_vpc ? 1 : 0
  subnet_id      = aws_subnet.private_1[0].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_route_table_association" "private_2" {
  count = var.create_custom_vpc ? 1 : 0
  subnet_id      = aws_subnet.private_2[0].id
  route_table_id = aws_route_table.private[0].id
}

# Route Table Associations - Database Subnets
resource "aws_route_table_association" "database_1" {
  count = var.create_custom_vpc ? 1 : 0
  subnet_id      = aws_subnet.database_1[0].id
  route_table_id = aws_route_table.database[0].id
}

resource "aws_route_table_association" "database_2" {
  count = var.create_custom_vpc ? 1 : 0
  subnet_id      = aws_subnet.database_2[0].id
  route_table_id = aws_route_table.database[0].id
}

# Private Subnet Security Group (More Restrictive)
resource "aws_security_group" "private-sg-vpc" {
  count = var.create_custom_vpc ? 1 : 0
  name        = "private-sg-vpc"
  description = "Security group for private subnets"
  vpc_id      = aws_vpc.main[0].id

  ingress {
    description = "Traffic from VPC only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/16"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg-vpc"
  }
}

