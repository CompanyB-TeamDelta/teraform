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

resource "aws_instance" "server" {

  ami           = "ami-0d7a109bf30624c99"
  instance_type = "t2.micro"
  subnet_id     = "subnet-073a11bb0b7e99abf"
  key_name      = "split-keys"
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
