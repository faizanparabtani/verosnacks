resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "public_az_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ca-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-az-a"
  }
}

resource "aws_subnet" "public_az_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ca-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-az-b"
  }
}

resource "aws_subnet" "private_az_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ca-central-1a"

  tags = {
    Name = "${var.project_name}-${var.environment}-private-az-a"
  }
}

resource "aws_subnet" "private_az_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ca-central-1b"

  tags = {
    Name = "${var.project_name}-${var.environment}-private-az-b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

resource "aws_eip" "nat_az_a" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip-nat-az-a"
  }
}

resource "aws_eip" "nat_az_b" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip-nat-az-b"
  }
}

# NAT Gateways — one per AZ, placed in public subnets.
# Each AZ routes through its own NAT GW — never share across AZs.
resource "aws_nat_gateway" "az_a" {
  allocation_id = aws_eip.nat_az_a.id
  subnet_id     = aws_subnet.public_az_a.id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-az-a"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "az_b" {
  allocation_id = aws_eip.nat_az_b.id
  subnet_id     = aws_subnet.public_az_b.id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-az-b"
  }

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rt-public"
  }
}

resource "aws_route_table_association" "public_az_a" {
  subnet_id      = aws_subnet.public_az_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_az_b" {
  subnet_id      = aws_subnet.public_az_b.id
  route_table_id = aws_route_table.public.id
}

# Private route tables — CRITICAL: each AZ routes to its own NAT GW.
# If AZ-a NAT fails and AZ-b routes through it, AZ-b tasks lose internet too.
resource "aws_route_table" "private_az_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az_a.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rt-private-az-a"
  }
}

resource "aws_route_table" "private_az_b" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az_b.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-rt-private-az-b"
  }
}

resource "aws_route_table_association" "private_az_a" {
  subnet_id      = aws_subnet.private_az_a.id
  route_table_id = aws_route_table.private_az_a.id
}

resource "aws_route_table_association" "private_az_b" {
  subnet_id      = aws_subnet.private_az_b.id
  route_table_id = aws_route_table.private_az_b.id
}

# S3 Gateway VPC Endpoint — free, avoids NAT data processing costs for S3 traffic
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_az_a.id,
    aws_route_table.private_az_b.id,
    aws_route_table.public.id,
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-vpce-s3"
  }
}

# DynamoDB Gateway VPC Endpoint — free, avoids NAT costs for DynamoDB/Terraform state traffic
resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_az_a.id,
    aws_route_table.private_az_b.id,
    aws_route_table.public.id,
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-vpce-dynamodb"
  }
}
