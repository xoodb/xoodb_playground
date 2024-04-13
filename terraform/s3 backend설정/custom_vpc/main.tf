# Create a VPC
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "xoodb_default_vpc_${var.env}"
  }
}

resource "aws_subnet" "public_subnet_1" {
  count             = var.env == "prd" ? 0 : 1 #prd면 public서브넷 생성x, 아니면 1로 생성
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "xoodb_public_1_${var.env}"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.default.id
  cidr_block        = "10.0.100.0/24"
  availability_zone = local.az_a

  tags = {
    Name = "xoodb_private_1_${var.env}"
  }
}

