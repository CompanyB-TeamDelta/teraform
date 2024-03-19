provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server" {
  ami           = "ami-04e914639d0cca79a"
  instance_type = "t2.micro"
  subnet_id = "${var.subnet_id}"
  key_name = "split-keys"
  user_data = <<EOF
#!/bin/bash

EOF
}
