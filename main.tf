provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  version = "~> 2.0"
}

resource "aws_vpc" "webinar_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Webinar_vpc"
  }
}
resource "aws_subnet" "webinar_subnet" {
  vpc_id     = aws_vpc.webinar_vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Webinar_subnet"
  }
}
# Internet gateway
resource "aws_internet_gateway" "webinar_gw" {
  vpc_id = aws_vpc.webinar_vpc.id
}

# Public Route Table
resource "aws_route_table" "webinar_public" {
  vpc_id = aws_vpc.webinar_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.webinar_gw.id
  }
}

# Route Table Assoc for Webinar_subnet
resource "aws_route_table_association" "webinar_rt" {
  subnet_id      = aws_subnet.webinar_subnet.id
  route_table_id = aws_route_table.webinar_public.id
}

resource "aws_security_group" "webinar_sg" {
  name        = "Webinar SG"
  vpc_id      = aws_vpc.webinar_vpc.id
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
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

resource "aws_key_pair" "hako" {
  key_name   = "hako-key"
  public_key = var.ssh_key
}

resource "aws_instance" "webinar" {
  ami                    = "ami-0e11cbb34015ff725"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.webinar_subnet.id
  key_name               = aws_key_pair.hako.key_name
  vpc_security_group_ids = [aws_security_group.webinar_sg.id]
  associate_public_ip_address= true


  tags = {
    Name = "Webinar"
  }
}
output "ip" {
  value = aws_instance.webinar.public_ip
}