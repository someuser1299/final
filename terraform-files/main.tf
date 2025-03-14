provider "aws" {
  region = var.region
}

resource "aws_key_pair" "liad_ssh_key_id" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_key_path)
}

# VPC with DNS support
resource "aws_vpc" "liad_main_vpc_id" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.main_vpc_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "liad_main_igw_id" {
  vpc_id = aws_vpc.liad_main_vpc_id.id

  tags = {
    Name = var.main_igw_name
  }
}

# Subnet
resource "aws_subnet" "liad_main_subnet_id" {
  vpc_id                  = aws_vpc.liad_main_vpc_id.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.az

  tags = {
    Name = var.main_subnet_name
  }
}

# Route Table
resource "aws_route_table" "liad_main_rt_id" {
  vpc_id = aws_vpc.liad_main_vpc_id.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.liad_main_igw_id.id
  }

  tags = {
    Name = var.main_rt_name
  }
}

# Route Table Association
resource "aws_route_table_association" "liad_rt_association_id" {
  subnet_id      = aws_subnet.liad_main_subnet_id.id
  route_table_id = aws_route_table.liad_main_rt_id.id
}

# Security Group
resource "aws_security_group" "liad_security_group_id" {
  name        = var.security_group_name
  vpc_id      = aws_vpc.liad_main_vpc_id.id

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
  ami                    = var.ami 
  instance_type          = var.instance_type
  key_name               = aws_key_pair.liad_ssh_key_id.key_name
  vpc_security_group_ids = [aws_security_group.liad_security_group_id.id]
  subnet_id              = aws_subnet.liad_main_subnet_id.id

  tags = {
    Name = "builder"
  }
}

# A null_resource that depends on the EC2 instance and handles Docker installation
resource "null_resource" "install_docker" {
  # This ensures the null_resource is created after the EC2 instance
  depends_on = [aws_instance.builder]

  # This ensures the null_resource is recreated if the instance is recreated
  triggers = {
    instance_id = aws_instance.builder.id
  }

  # Copy the installation script
  provisioner "file" {
    source      = "${path.module}/install_docker.sh"
    destination = "/tmp/install_docker.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/liad_ssh_key")
      host        = aws_instance.builder.public_ip
      timeout     = "5m"
      agent       = false
    }
  }

  # Execute the installation script
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh",
      "/tmp/install_docker.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/liad_ssh_key")
      host        = aws_instance.builder.public_ip
      timeout     = "5m"
      agent       = false
    }
  }
}