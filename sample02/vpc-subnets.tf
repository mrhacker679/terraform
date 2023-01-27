#Create VPC
resource "aws_vpc" "test-vpc" {
  cidr_block       = var.vpc-cidr

  tags = {
    Name = "test-vpc"
  }
}

#Create private subnets
resource "aws_subnet" "private-subnets" {
  vpc_id = aws_vpc.test-vpc.id
  count = length(var.azs)
  cidr_block = element(var.private-subnets , count.index)
  availability_zone = element(var.azs , count.index)

  tags = {
    Name = "private-subnet-${count.index+1}"
  }
}

#Create public subnets
resource "aws_subnet" "public-subnets" {
  vpc_id = aws_vpc.test-vpc.id
  count = length(var.azs)
  cidr_block = element(var.public-subnets , count.index)
  availability_zone = element(var.azs , count.index)

  tags = {
    Name = "public-subnet-${count.index+1}"
  }
}


#Create IGW
resource "aws_internet_gateway" "test-igw" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "test-igw"
  }
}

#Single route table for public subnet
resource "aws_route_table" "public-rtable" {
  vpc_id = aws_vpc.test-vpc.id

  tags = {
    Name = "public-rtable"
  }
}

#add routes to public-rtable
resource "aws_route" "public-rtable" {
  route_table_id            = aws_route_table.public-rtable.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.test-igw.id
}

#route table association public subnets
resource "aws_route_table_association" "public-subnet-association" {
  count          = length(var.public-subnets)
  subnet_id      = element(aws_subnet.public-subnets.*.id , count.index)
  route_table_id = aws_route_table.public-rtable.id
}

#private route tables
resource "aws_route_table" "private-rtable" {
  count          = length(var.private-subnets)
  vpc_id         = aws_vpc.test-vpc.id

  tags = {
    Name = "private-rtable-${count.index+1}"
  }
}

#route table association private subnets
resource "aws_route_table_association" "private-subnet-association" {
  count          = length(var.private-subnets)
  subnet_id      = element(aws_subnet.private-subnets.*.id , count.index)
  route_table_id = element(aws_route_table.private-rtable.*.id , count.index)
}

#3 x EIP
resource "aws_eip" "nat-eip" {
  count    = length(var.azs)
  vpc      = true

  tags = {
    Name = "EIP--${count.index+1}"
  }
}

#3 x NAT gateways
resource "aws_nat_gateway" "prod-nat-gateway" {
  count         = length(var.azs)
  allocation_id = element(aws_eip.nat-eip.*.id , count.index)
  subnet_id     = element(aws_subnet.public-subnets.*.id , count.index)

  tags = {
    Name = "NAT-GW--${count.index+1}"
  }
}

#add routes to private-rtable
resource "aws_route" "subnets-private-rtable" {
  count                     = length(var.azs)
  route_table_id            = element(aws_route_table.private-rtable.*.id , count.index)
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = element(aws_nat_gateway.prod-nat-gateway.*.id, count.index)
}
