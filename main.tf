provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  version = "~> 2.0"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
resource "aws_vpc" "webinar" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Webinar_vpc"
  }
}
resource "aws_subnet" "webinar" {
  vpc_id     = aws_vpc.webinar.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Webinar_subnet"
  }
}
resource "aws_security_group" "base" {
  name        = "Base SG"

  # Outbound HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = false
  }

  vpc_id = aws_vpc.webinar.id

}

resource "aws_key_pair" "hako" {
  key_name   = "hako-key"
  public_key = var.ssh_key
}

resource "aws_instance" "webinar" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id              = aws_subnet.webinar.id
  key_name               = aws_key_pair.hako.id
  vpc_security_group_ids = [aws_security_group.base.id]


  tags = {
    Name = "Webinar"
  }
}