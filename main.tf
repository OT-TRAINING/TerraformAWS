provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "local" {
    path = "/tmp/terraform.tfstate"
  }
}

variable "resource_name" {  }
 
#  create VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = var.resource_name
  }
}

# create public subnet
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id 
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
    tags = {
        Name = "${var.resource_name}-subnet"
}
}

# for ami
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

# create ec-2
resource "aws_instance" "main" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.main.id]  
  tags = {
    Name = "${var.resource_name}-instance"
  }
}
# Create the Security Group
resource "aws_security_group" "main" {
  vpc_id       = aws_vpc.main.id
  name         = "main Security Group"
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }   
  
  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
   Name = "${var.resource_name}-SG"
}
}

