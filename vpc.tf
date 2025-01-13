resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id # it will fetch VPC ID created from the below code 
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet-automated_vpc"
  }
}
resource "aws_vpc" "main"{ #this name belongs to only terraform purpose
 cidr_block       = "10.0.0.0/16"
 instance_tenancy = "default"
 tags = {
    Name = "automated_vpc" #this name belongs to aws
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id # it will fetch VPC ID created from the above code 
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet-automated_vpc"
  }
}

resource "aws_internet_gateway" "automated-igw" {
  vpc_id = aws_vpc.main.id # internet gateway depends on VPC

  tags = {
    Name = "automated-igw"
  }
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.automated-igw.id
  }

  tags = {
    Name = "public-route"
  }
}

resource "aws_eip" "auto-eip" {

}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.auto-eip.id
  subnet_id     = aws_subnet.main.id

  tags = {
    Name = "automated-NAT-GATEWAY"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.automated-igw]
}

resource "aws_route_table" "private-route" { # for private route don't attach IGW, we attach NAT Gateway Only.
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example.id
  }

  tags = {
    Name = "private-route"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public-route.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-route.id
}