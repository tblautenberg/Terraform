# Test script til Terraform. Lavet med Chat GPT da jeg ikke har erfaring med Terraform. Arbejder med LocalStack til at simulere AWS services. 
# Scriptet starter 5 EC2 instancer og installerer Nginx på hver af dem.
# Alle køre lokalt i en docker container med localstack, og kan ikke tilgås via LH eller IP.
# Prøv det ^^

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
  ami           = "ami-06ca3ca175f37dd66"  # Amazon machine images (AMI) for Ubuntu 20.04 (køre op EC2)
  instance_type = "t2.micro"
  count         = 5

  # Starter vores EC2 server og installerer Nginx (chatGPT)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              echo "<h1>Hello World from Instance ${count.index}</h1>" > /var/www/html/index.html
              sudo systemctl restart nginx
            EOF

  # Åbner port 80
  security_groups = [aws_security_group.web_server_sg.name]

  tags = {
    Name = "web-server-${count.index}"
  }
}

# Protokol for at tillade HTTP trafik
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
