#############################################
# VPC
#############################################

resource "aws_vpc" "usage_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "usage-vpc"
  }
}

#############################################
# Internet Gateway (for public subnets)
#############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.usage_vpc.id

  tags = {
    Name = "usage-igw"
  }
}

#############################################
# Public Subnets
#############################################

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.usage_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.usage_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-b"
  }
}

#############################################
# Private Subnets (Lambda + RDS)
#############################################

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.usage_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "private-a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.usage_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "private-b"
  }
}

#############################################
# Public Route Table (Internet access)
#############################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.usage_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

#############################################
# NAT Gateway (Internet access for private subnets)
#############################################

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "usage-nat"
  }
}

#############################################
# Private Route Table (Routes through NAT)
#############################################

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.usage_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}