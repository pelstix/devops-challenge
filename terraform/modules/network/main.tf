# Define the main VPC with a CIDR block and enable DNS support and hostnames
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Create a public subnet in the specified availability zone
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "public-subnet"
  }
}

# Create a private subnet in the specified availability zone
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "private-subnet"
  }
}

# Create an internet gateway for public access to instances in the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "internet-gateway"
  }
}

# Allocate an Elastic IP for the NAT gateway in the public subnet
resource "aws_eip" "nat_eip" {
  domain = "vpc"  # Use 'vpc' for Elastic IPs associated with VPC

  tags = {
    Name = "nat-eip"
  }
}

# Allocate an Elastic IP for the Bastion host in the public subnet
resource "aws_eip" "bastion_eip" {
  instance = var.instance

  tags = {
    Name = "example-eip"
  }
}


# Create a NAT gateway in the public subnet to provide internet access for instances in the private subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "nat-gateway"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate the public route table with the public subnet
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate the private route table with the private subnet
resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# Create a public subnet in the second availability zone (AZ2)
resource "aws_subnet" "public_subnet_az2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2b"  # Different AZ

  tags = {
    Name = "public-subnet-az2"
  }
}

resource "aws_route_table_association" "public_rta_az2" {
  subnet_id      = aws_subnet.public_subnet_az2.id
  route_table_id = aws_route_table.public_rt.id
}

