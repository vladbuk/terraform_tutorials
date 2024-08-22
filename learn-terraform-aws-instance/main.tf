terraform {

    cloud { 
    organization = "vladbuk-inc" 
    workspaces { 
      name = "learning" 
    } 
  } 

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_key_pair" "vboook" {
  key_name = "vboook"
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "basic_sg" {
  name        = "basic_sg"
  description = "Allow SSH, HTTP, HTTPS and ICMP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.vboook.key_name
  security_groups = [aws_security_group.basic_sg.name]

  tags = {
    Name = var.instance_name
  }
}


output "instance_id" {
  description = "The ID of the EC2 instances"
  value       = aws_instance.app_server[*].id
}

output "public_ip" {
  description = "The public IP address of the EC2 instances"
  value       = aws_instance.app_server[*].public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instances"
  value       = aws_instance.app_server[*].private_ip
}
