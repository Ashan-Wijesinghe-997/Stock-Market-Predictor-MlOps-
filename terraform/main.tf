provider "aws" {
  region = "us-east-1"
}

# Data source for the existing EC2 instance
data "aws_instance" "existing_instance" {
  instance_id = "i-000268ebf429d0436"  # Replace with your actual EC2 instance ID
}

# Security group for the application
resource "aws_security_group" "app_sg" {
  name        = "stock-predictor-sg"
  description = "Security group for stock predictor application"
  vpc_id      = data.aws_instance.existing_instance.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow backend API access"
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow frontend access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "stock-predictor-sg"
  }
}

# Attach the security group to the existing EC2 instance's network interface
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