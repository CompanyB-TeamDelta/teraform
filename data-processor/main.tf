provider "aws" {
  region = "us-east-1"
}

backend "s3" {
    bucket                  = "terraform-s3-state-hwnaukma2024"
    key                     = "proj"
    region                  = "us-east-1"
  }

resource "aws_instance" "server" {

  provisioner "file" {
      source      = "data-processor.tar"
      destination = "/home/ec2-user/data-processor.tar"
  }

  ami           = "ami-0d7a109bf30624c99"
  instance_type = "t2.micro"
  subnet_id     = "subnet-073a11bb0b7e99abf"
  key_name      = "split-keys"
  user_data     = <<EOF
#!/bin/bash

EOF
}
