resource "aws_vpc" "tynybay_vpc" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_internet_gateway" "tynybay_gw" {
  vpc_id = aws_vpc.tynybay_vpc.id

  tags = local.common_tags
}

resource "aws_subnet" "tynybay_subnet_1" {
  vpc_id            = aws_vpc.tynybay_vpc.id
  cidr_block        = var.subnet_cidr_block[0]
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = local.common_tags
}

resource "aws_subnet" "tynybay_subnet_2" {
  vpc_id            = aws_vpc.tynybay_vpc.id
  cidr_block        = var.subnet_cidr_block[1]
  availability_zone = data.aws_availability_zones.available.names[1]

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


resource "aws_route_table_association" "tynybay_route_table_association_1" {
  subnet_id      = aws_subnet.tynybay_subnet_1.id
  route_table_id = aws_route_table.tynybay_route_table.id
}

resource "aws_route_table_association" "tynybay_route_table_association_2" {
  subnet_id      = aws_subnet.tynybay_subnet_2.id
  route_table_id = aws_route_table.tynybay_route_table.id
}


resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.tynybay_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
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

resource "aws_security_group" "for_lb" {
  name        = "for_lb"
  description = "Allow lb inbound traffic"
  vpc_id      = aws_vpc.tynybay_vpc.id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

