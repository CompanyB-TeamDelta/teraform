provider "aws" {
  region = "us-east-1"
}

terraform{
  backend "s3" {
      bucket                  = "terraform-s3-state-hwnaukma2024"
      key                     = "tgproc"
      region                  = "us-east-1"
    }
}


resource "aws_instance" "server" {

  ami           = "ami-0d7a109bf30624c99"
  instance_type = "t2.micro"
  subnet_id     = "subnet-0c75f7a440c143dc5"
  key_name      = "split-keys"
  security_groups = ["sg-0c41e577818bc0a08"]
  iam_instance_profile = "log-role"
  tags = {
    Name = "telegram-proc"
  }

  provisioner "file" {
    source      = "tg-proc.tar"
    destination = "tg-proc.tar"

    connection {
      type        = "ssh"
      user        = "ec2-user"  # Or your AMI's default user
      private_key = file("key.pem")
      host        = self.public_ip
    }
  }
  provisioner "file" {
      source      = "tg-proc2.tar"
      destination = "tg-proc2.tar"
  
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
      "sudo docker load < tg-proc.tar",
      "sudo docker load < tg-proc.tar2",
      "sudo docker run -d -it --log-driver=awslogs --log-opt awslogs-region=us-east-1  --log-opt awslogs-group=logs --log-opt awslogs-stream=telegram-proc --log-opt awslogs-create-group=false --name tg-proc tg-proc",
      "sudo docker run -d -it --log-driver=awslogs --log-opt awslogs-region=us-east-1  --log-opt awslogs-group=logs --log-opt awslogs-stream=telegram-proc --log-opt awslogs-create-group=false --name tg-proc2 tg-proc2",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"  # Or your AMI's default user
      private_key = file("key.pem")
      host        = self.public_ip
    }
  }
}
