resource "aws_instance" "web_1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.tynybay_subnet_1.id
  security_groups             = [aws_security_group.allow_http.id]

  tags      = local.common_tags
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


resource "aws_instance" "web_2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.tynybay_subnet_2.id
  security_groups             = [aws_security_group.allow_http.id]

  tags      = local.common_tags
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
