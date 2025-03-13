variable "region" {
    default = "us-east-1"
}

variable "ami" {
    default = "ami-0e1bed4f06a3b463d" # ubuntu
}

variable "instance_type" {
    default = "t2.micro"
  
}

variable "ssh_key_name" {
    default = "liad_ssh_key"
}

variable "ssh_key_path" {
    default = "~/.ssh/liad_ssh_key.pub"
}

variable "security_group_name" {
    default = "liad_security_group_name"
}

variable "az" {
    default = "us-east-1a"
}

