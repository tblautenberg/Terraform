terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-06ca3ca175f37dd66"  # Dummy AMI for LocalStack simulation
  instance_type = "t2.micro"
  count         = 5

  # Startup script to install Nginx and create an HTML page
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              echo "<h1>Hello World from Instance ${count.index}</h1>" > /var/www/html/index.html
              sudo systemctl restart nginx
            EOF

  # Open HTTP port 80
  security_groups = [aws_security_group.web_server_sg.name]

  tags = {
    Name = "web-server-${count.index}"
  }
}

# Security group to allow HTTP traffic
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
