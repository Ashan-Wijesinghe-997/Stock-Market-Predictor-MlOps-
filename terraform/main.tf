provider "aws" {
  region = "us-east-1"
}

data "aws_instance" "existing_instance" {
  filter {
    name   = "tag:Name"
    values = ["i-000268ebf429d0436"]  # Replace with your EC2 instance name
  }
}

output "public_ip" {
  value = data.aws_instance.existing_instance.public_ip
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "stock-predictor-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block             = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "stock-predictor-public-subnet"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "stock-predictor-sg"
  description = "Security group for stock predictor application"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port   = 8000
    to_port     = 8000
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

resource "aws_instance" "app_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name      = "your-key-pair-name"

  tags = {
    Name = "stock-predictor-server"
  }
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}