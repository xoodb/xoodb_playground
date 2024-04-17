# Create a VPC
resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "xoodb_default_vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.default_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "xoodb_public_1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.default_vpc.id
  cidr_block = "10.0.100.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "xoodb_private_1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Name = "xoodb_default_vpc_IGW"
  }
}

resource "aws_eip" "nat_ip" {
  domain   = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "private_nat" {
  allocation_id     = aws_eip.nat_ip.id
  subnet_id         = aws_subnet.private_subnet_1.id
  tags = {
    Name = "xoodb_NAT"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.default_vpc.id
  tags = {
    Name = "public-rt"
  }
}

resource "aws_route" "public_worldwide" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id   = aws_vpc.default_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_nat.id
  }
  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}