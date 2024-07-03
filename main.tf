provider "aws" {
  region = var.region
}

resource "aws_vpc" "jenkins_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "jenkins-vpc"
    # Environment = var.environment
  }
}

resource "aws_subnet" "jenkins_subnet" {
  vpc_id     = aws_vpc.jenkins_vpc.id
  cidr_block = "10.0.1.0/24"
  # availability_zone = var.availability_zone
  tags = {
    Name = "jenkins-subnet"
  }
}

resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id
  tags = {
    Name = "jenkins-igw"
  }
}

resource "aws_route_table" "jenkins_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }
  tags = {
    Name = "jenkins-rt"
  }
}

resource "aws_route_table_association" "jenkins_rta" {
  subnet_id      = aws_subnet.jenkins_subnet.id
  route_table_id = aws_route_table.jenkins_rt.id
}

resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.jenkins_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ssh access temporarily enabled for debugging
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins-sg"
  }
}

resource "aws_instance" "jenkins_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.jenkins_subnet.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  user_data                   = <<-EOF
    #!/bin/bash
    sudo certbot --nginx -d ${var.domain} --register-unsafely-without-email --agree-tos --test-cert
  EOF
  tags = {
    Name = "jenkins-instance"
  }
}

data "aws_eip" "jenkins_eip" {
  id = var.elastic_ip_allocation_id
}

resource "aws_eip_association" "jenkins_eip_assoc" {
  instance_id   = aws_instance.jenkins_instance.id
  allocation_id = data.aws_eip.jenkins_eip.id
  # allocation_id = var.elastic_ip_allocation_id
}
