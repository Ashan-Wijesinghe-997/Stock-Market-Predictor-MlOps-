provider "aws" {
  region = "us-east-1"
}

# Data source for the existing EC2 instance
data "aws_instance" "existing_instance" {
  instance_id = "i-000268ebf429d0436"
}

# Data source for the existing VPC
data "aws_vpc" "existing_vpc" {
  id = data.aws_instance.existing_instance.subnet.vpc_id
}

# Data source for the existing subnet
data "aws_subnet" "existing_subnet" {
  id = data.aws_instance.existing_instance.subnet_id
}

# Security group for the application
resource "aws_security_group" "app_sg" {
  # ... existing security group configuration ...
}

# Update the network interface with the new security group
resource "aws_network_interface" "instance_eni" {
  id = data.aws_instance.existing_instance.network_interface_id[0]
  security_groups = [aws_security_group.app_sg.id]
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