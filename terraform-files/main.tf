provider "aws" {
  region = var.region
}

resource "aws_key_pair" "liad_ssh_key_id" {
  key_name   = var.ssh_key_name
  public_key = file(var.ssh_key_path)
}

resource "aws_security_group" "liad_security_group_id" {
  name        = var.security_group_name

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
  security_groups = [aws_security_group.liad_security_group_id.name]

  tags = {
    Name = "builder"
  }
}

