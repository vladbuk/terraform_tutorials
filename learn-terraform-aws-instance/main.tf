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

provider "aws" {
  region = "eu-central-1"
  profile = "default"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_key_pair" "deploy" {
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
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
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
  count         = 1
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = data.aws_key_pair.deploy.key_name
  security_groups = [aws_security_group.basic_sg.name]
  root_block_device {
    volume_size = 16 
  }

  user_data = <<-EOF
            #!/bin/bash
            add-apt-repository --yes ppa:deadsnakes/ppa
            apt update -y
            apt install -y sqlite3 python3.10 python3.10-venv python3.10-dev python3-virtualenv
            wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
            dpkg -i google-chrome-stable_current_amd64.deb; apt-get -fy install
            cd /opt
            git clone https://github.com/dimafil1903/tyres-scrap.git
            cd tyres-scrap
            virtualenv --python=/usr/bin/python3.10 venv
            source venv/bin/activate
            python -m ensurepip --upgrade
            wget https://bootstrap.pypa.io/get-pip.py -P venv/bin/
            python venv/bin/get-pip.py
            pip install sqlalchemy aiohttp fake_useragent selenium free-proxy undetected_chromedriver Proxy_List_Scrapper bs4 mss pydantic databases aiosqlite
            fallocate -l 4G /swapfile
            dd if=/dev/zero of=/swapfile bs=1M count=4096
            chmod 600 /swapfile
            mkswap /swapfile
            swapon /swapfile
            echo "/swapfile       none    swap    sw      0       0" | tee -a /etc/fstab
            cd /root
            wget https://git.io/vpn -O openvpn-install.sh
            EOF

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
