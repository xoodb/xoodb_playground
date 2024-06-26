# Create a VPC
resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "xoodb_default_vpc_${var.env}"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.default_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "xoodb_public_1_${var.env}"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.default_vpc.id
  cidr_block = "10.0.100.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "xoodb_private_1_${var.env}"
  }
}

resource "aws_nat_gateway" "private_nat" {
  connectivity_type = "private"
  subnet_id         = aws_subnet.private_subnet_1.id

  tags = {
    Name = "xoodb_nat_${var.env}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "xoodb_igw_${var.env}"
  }
}

