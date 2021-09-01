terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-3"
  access_key = ""
  secret_key = ""
}


# 1. Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "backoffice-vpc"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-in-gate"
  }
}

# 3. Create Custom Route Table
resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "my-rtable"
  }
}

# 4. Create Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "my-subnet-ex"
  }
}

# 5. Associate Subnet with Route Table
resource "aws_route_table_association" "route-ass" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.rtable.id
}

# 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow WEB traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "HTTPS traffic"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "HTTP traffic"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    # que devices tienen acceso. si pongo esto entiendo que todos dentro de la VPC
    #cidr_blocks      = [aws_vpc.my_vpc.cidr_block]
    cidr_blocks      = ["0.0.0.0/0"]
  }
  ingress {
    description      = "SSH traffic"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    # any protocol
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Crate a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["10.0.0.50"]
  security_groups = [aws_security_group.allow_web.id]
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.0.50"
  depends_on                = [aws_internet_gateway.gw]
}

# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami           = "ami-06602da18c878f98d"
  instance_type = "t2.micro"
  availability_zone = "eu-west-3a"
  key_name      = "aws-dgp-kp"

  network_interface {
    network_interface_id = aws_network_interface.web-server-nic.id
    device_index         = 0
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemctl start apache2
                sudo bash -c 'echo Nacho aquí tu backoffice > /var/www/html/index.html'
                EOF

  tags = {
    Name = "backoffice"
  }
}

#sudo apt install apache2 -y
                #sudo systemctl start apache2
                #sudo bash -c 'echo Nacho aquí tu backoffice > /var/www/html/index.html'