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
EOF
}
