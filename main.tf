# This file contains the main configuration of the infrastructure

# VPC Configuration
resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "Jenkins VPC ${var.vpc_id}"
  }
}

# Availability Zones
data "aws_availability_zones" "all" {
  state = "available"
}

# Subnets Configuration
resource "aws_subnet" "jenkins_subnet" {
  count                   = var.public_subnet
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block, 1, count.index)
  availability_zone       = element(data.aws_availability_zones.all.names, count.index % length(data.aws_availability_zones.all.names))
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet ${count.index + 1} - VPC ${var.vpc_id}"
  }

}

# Internet Gateway Configuration
resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id

  tags = {
    Name = "Internet gateway"
  }
}


# Route Table Configuration
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

# Route Table Association
resource "aws_route_table_association" "aws_public_route_table_association" {
  count          = var.public_subnet
  subnet_id      = aws_subnet.jenkins_subnet[count.index].id
  route_table_id = aws_route_table.jenkins_rt.id
}

# Security Group Configuration
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_application"
  description = "Allow TLS inbound/outbound traffic"
  vpc_id      = aws_vpc.jenkins_vpc.id

  ingress {
    description = "HTTP from VPC"
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
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outbound traffic"
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

# Key Pair
resource "aws_key_pair" "ssh_key" {
  key_name   = "jenkins_ssh"
  public_key = file(var.public_key_path)
}

# EC2 Instance Configuration
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.latest_jenkins_ami.id
  instance_type          = "t2.large"
  key_name               = aws_key_pair.ssh_key.key_name
  subnet_id              = aws_subnet.jenkins_subnet[0].id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = templatefile("${path.module}/user_data.sh", {
    domain_name = var.domain_name
    email       = var.email
  })

  root_block_device {
    delete_on_termination = true
    volume_size           = 50
    volume_type           = "gp2"
  }

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [aws_route53_record.jenkins_dns]

  tags = {
    Name = "Jenkins Server"
  }
}

# Elastic IP Configuration
resource "aws_eip" "jenkins_eip" {
  domain   = "vpc"
  instance = aws_instance.jenkins_server.id
}

# Route53 Hosted Zone
data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

# Route53 Record Configuration
resource "aws_route53_record" "jenkins_dns" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = data.aws_route53_zone.hosted_zone.name
  type    = "A"
  ttl     = "60"
  records = [aws_eip.jenkins_eip.public_ip]
}
