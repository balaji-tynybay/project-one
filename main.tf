data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_vpc" "tynybay_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_internet_gateway" "tynybay_gw" {
  vpc_id = aws_vpc.tynybay_vpc.id

  tags = local.common_tags
}

resource "aws_subnet" "tynybay_subnet_1" {
  vpc_id     = aws_vpc.tynybay_vpc.id
  cidr_block = var.subnet_cidr_block

  tags = local.common_tags
}


resource "aws_route_table" "tynybay_route_table" {
  vpc_id = aws_vpc.tynybay_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tynybay_gw.id
  }

  tags = local.common_tags
}


resource "aws_route_table_association" "tynybay_route_table_association" {
  subnet_id      = aws_subnet.tynybay_subnet_1.id
  route_table_id = aws_route_table.tynybay_route_table.id
}


resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.tynybay_vpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.common_tags
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.tynybay_subnet_1.id
  security_groups = [aws_security_group.allow_http.id]

  tags = local.common_tags
  user_data = <<EOF
#!/bin/bash

# Update system packages
apt update && apt upgrade -y

# Install Nginx
apt install nginx -y

# Start Nginx
systemctl start nginx

# Enable Nginx on system boot
systemctl enable nginx


EOF
}
