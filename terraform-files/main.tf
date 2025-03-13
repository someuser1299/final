provider "aws" {
  region = var.region
}

resource "aws_key_pair" "liad_ssh_key_id" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_key_path)
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

}



resource "aws_security_group" "liad_security_group_id" {
  name        = var.security_group_name
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "builder" {
  ami             = var.ami 
  instance_type   = var.instance_type
  key_name        = aws_key_pair.liad_ssh_key_id.key_name
  vpc_security_group_ids   = [aws_security_group.liad_security_group_id.id]
  subnet_id       = aws_subnet.main_subnet.id

  tags = {
    Name = "builder"
  }
}

