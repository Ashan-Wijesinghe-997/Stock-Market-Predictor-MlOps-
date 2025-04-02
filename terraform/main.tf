provider "aws" {
  region = "us-east-1"
}

# Data source for the existing EC2 instance
data "aws_instance" "existing_instance" {
  instance_id = "i-000268ebf429d0436"
}

# Data source for the existing VPC
data "aws_vpc" "existing_vpc" {
  id = data.aws_instance.existing_instance.vpc_id
}

# Data source for the existing subnet
data "aws_subnet" "existing_subnet" {
  id = data.aws_instance.existing_instance.subnet_id
}

# Security group for the application
resource "aws_security_group" "app_sg" {
  name        = "stock-predictor-sg"
  description = "Security group for stock predictor application"
  vpc_id      = data.aws_vpc.existing_vpc.id

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

# Update the network interface with the new security group
resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.app_sg.id
  network_interface_id = data.aws_instance.existing_instance.network_interface_id
}

# Outputs
output "instance_public_ip" {
  value       = data.aws_instance.existing_instance.public_ip
  description = "The public IP address of the EC2 instance"
}

output "instance_private_ip" {
  value       = data.aws_instance.existing_instance.private_ip
  description = "The private IP address of the EC2 instance"
}

output "security_group_id" {
  value       = aws_security_group.app_sg.id
  description = "The ID of the security group"
}

output "vpc_id" {
  value       = data.aws_vpc.existing_vpc.id
  description = "The ID of the VPC"
}