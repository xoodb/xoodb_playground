/* 반복적으로 사용하는 값들은 local에 저장 */
locals {
  az_a = "ap-northeast-2a"
  az_c = "ap-northeast-2c"
}

# Create a VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "${var.env}_jty_default_vpc"
  }
}

# Create public, private subnet each 2
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "${var.env}_public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.az_c

  tags = {
    Name = "${var.env}_public_subnet_2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "${var.env}_private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = local.az_c

  tags = {
    Name = "${var.env}_private_subnet_2"
  }
}

# vpc IGW
resource "aws_internet_gateway" "eks_IGW" {
  vpc_id = aws_vpc.eks_vpc.id
  

  tags = {
    Name = "${var.env}_jty_default_vpc_IGW"
  }
}

# nat IP
resource "aws_eip" "ngw_ip" {
  domain = "vpc"
}

# vpc NAT
resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.ngw_ip.id
  subnet_id     = aws_subnet.private_subnet_1.id
  tags = {
    Name = "${var.env}_jty_default_vpc_NAT"
  }
  depends_on = [aws_internet_gateway.eks_IGW]
}