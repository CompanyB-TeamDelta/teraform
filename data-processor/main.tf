provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server" {
  ami           = "ami-0d7a109bf30624c99"
  instance_type = "t2.micro"
  subnet_id     = "vpc-0bba69cece42aa727"
  key_name      = "split-keys"
  user_data     = <<EOF
#!/bin/bash

EOF
}
