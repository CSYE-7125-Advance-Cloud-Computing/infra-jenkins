# VPC
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

    tags = {
        Name = "Jenkins VPC"
    }
}

# Subnets
resource "aws_subnet" "jenkins_subnet" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet - VPC ${aws_vpc.jenkins_vpc.id}"
  }

}

# Internet Gateway
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "Internet gateway"
  }
}

# Route Table
resource "aws_route_table" "jenkins_rt" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.jenkins_igw.id
  }

  tags = {
    Name = "Public route table"
  }
}

# Security Group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_application"
  description = "Allow TLS inbound/outbound traffic"
  vpc_id = aws_vpc.jenkins_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "TLS from VPC"
    from_port   = 8080
    to_port     = 8080
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

# Data source to get the latest Jenkins AMI ID
data "aws_ami" "latest_jenkins_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["jenkins*"]
  }

}

resource "aws_key_pair" "ssh_key" {
  key_name   = "jenkins_ssh"
  public_key = var.rsa_public
}

# EC2 Instance
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.latest_jenkins_ami.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name
  subnet_id     = aws_subnet.jenkins_subnet.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = templatefile("${path.module}/user_data.sh", {
    domain_name = var.domain_name
    email       = var.email
  })

  tags = {
    Name = "Jenkins Server"
  }
}

# Elastic IP
resource "aws_eip" "jenkins_eip" {
  domain = "vpc"
  instance = aws_instance.jenkins_server.id
}

data "aws_route53_zone" "hosted_zone" {
  name = "${var.domain_name}"
}

# Route53 Record
resource "aws_route53_record" "jenkins_dns" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = data.aws_route53_zone.hosted_zone.name
  type    = "A"
  ttl     = "60"
  records = [aws_eip.jenkins_eip.public_ip]
}

