provider "aws" {
  region = "us-east-1"
}

terraform{
  backend "s3" {
      bucket                  = "terraform-s3-state-hwnaukma2024"
      key                     = "proj"
      region                  = "us-east-1"
    }
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

resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.CustomVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table_association" "PublicSubnetRouteTableAssociation1" {
  subnet_id      = aws_subnet.PublicSubnet1.id
  route_table_id = aws_route_table.PublicRouteTable.id
}

resource "aws_instance" "server2" {

  ami           = "ami-0d7a109bf30624c99"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.PublicSubnet1.id
  key_name      = "split-keys"
  security_groups = [aws_security_group.ec2_sg.id]
  iam_instance_profile = "log-role"

  tags = {
    Name = "dataproc"
  }

  provisioner "file" {
    source      = "telegram-management.tar"
    destination = "telegram-management.tar"

    connection {
      type        = "ssh"
      user        = "ec2-user"  # Or your AMI's default user
      private_key = file("key.pem")
      host        = self.public_ip
    }
  }
  provisioner "file" {
    source      = "data-processor.tar"
    destination = "data-processor.tar"

    connection {
      type        = "ssh"
      user        = "ec2-user"  # Or your AMI's default user
      private_key = file("key.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install docker -y",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker load < data-processor.tar",
      "sudo docker load < telegram-management.tar",
      "sudo docker run -d -p 8080:8080 -it --log-driver=awslogs --log-opt awslogs-region=us-east-1  --log-opt awslogs-group=logs --log-opt awslogs-stream=data-proc --log-opt awslogs-create-group=false --name data-processor data-processor",
      "sudo docker run -d -p 8088:8080 -it --log-driver=awslogs --log-opt awslogs-region=us-east-1  --log-opt awslogs-group=logs --log-opt awslogs-stream=tg-management --log-opt awslogs-create-group=false --name telegram-management telegram-management",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"  # Or your AMI's default user
      private_key = file("key.pem")
      host        = self.public_ip
    }
  }
}
