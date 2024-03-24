provider "aws" {
  region = "us-east-1"
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id     = aws_vpc.CustomVPC.id
  cidr_block = "10.0.0.0/18"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet1"
    Type = "Public"
  }
}

resource "aws_vpc" "CustomVPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "CustomVPC"
           }
}

resource "aws_internet_gateway" "igw" { 
vpc_id = aws_vpc.CustomVPC.id
tags = { Name = "IGW" } 
}


resource "aws_security_group" "ec2_sg" {
  name        = "split"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.CustomVPC.id

  ingress {
    from_port   = 443
    to_port     = 443
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 8088
    to_port     = 8088
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-ec2-split-keys"
  }
}

terraform{
  backend "s3" {
      bucket                  = "terraform-s3-state-hwnaukma2024"
      key                     = "proj"
      region                  = "us-east-1"
    }
}

resource "aws_instance" "server" {

  ami           = "ami-0d7a109bf30624c99"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.PublicSubnet1.id
  key_name      = "split-keys"
  security_groups = [aws_security_group.ec2_sg.id]
  user_data     = <<EOF
#!/bin/bash
scp -i key.pem data-processor.tar ec2-user@ec2-3-90-110-214.compute-1.amazonaws.com
scp -i key.pem telegram-management.tar ec2-user@ec2-3-90-110-214.compute-1.amazonaws.com
ssh -i key.pem ec2-user@ec2-54-204-100-254.compute-1.amazonaws.com
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo docker load < data-processor.tar
sudo docker load < telegram-management.tar
sudo docker run -d -p 8080:8080 --name data-processor
sudo docker run -d -p 8088:8080 --name telegram-management
EOF
}
