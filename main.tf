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
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "tynybay_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "tynybay_subnet_1" {
  vpc_id     = aws_vpc.tynybay_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}


resource "aws_route_table" "tynybay_route_table" {
  vpc_id = aws_vpc.tynybay.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tynybay_gw.id
  }

  tags = {
    Name = "Route table"
  }
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

  tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = true
  user_data = <<EOF
  #!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

# Install Nginx
sudo apt install nginx -y

# Start Nginx
sudo systemctl start nginx

# Enable Nginx on system boot
sudo systemctl enable nginx

# Create a new server block configuration file for your website
sudo bash -c 'cat > /etc/nginx/sites-available/mywebsite.conf <<EOF
server {
    listen 80;
    server_name mywebsite.com;

    root /var/www/mywebsite;
    index index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF'

# Create a symbolic link to enable the new configuration
sudo ln -s /etc/nginx/sites-available/mywebsite.conf /etc/nginx/sites-enabled/

# Restart Nginx
sudo systemctl restart nginx
EOF
  security_groups = [aws_security_group.allow_http]

  tags = {
    Name = "web 1"
  }
}