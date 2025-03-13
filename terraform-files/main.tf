provider "aws" {
  region = var.region
}

resource "aws_key_pair" "liad_ssh_key_id" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_key_path)
}

# VPC with DNS support
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az

  tags = {
    Name = "main-subnet"
  }
}

# Route Table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "main-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main.id
}

# Security Group
resource "aws_security_group" "liad_security_group_id" {
  name        = var.security_group_name
  vpc_id      = aws_vpc.main.id

  # Inbound SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound port 5001
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP (ping)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "builder" {
  ami             = var.ami 
  instance_type   = var.instance_type
  key_name        = aws_key_pair.liad_ssh_key_id.key_name
  vpc_security_group_ids = [aws_security_group.liad_security_group_id.id]
  subnet_id       = aws_subnet.main_subnet.id

  tags = {
    Name = "builder"
  }
}