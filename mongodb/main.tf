
provider "aws" {
  region = var.region
}


data "aws_availability_zones" "available" {
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "vpc-mongo-devl"
  cidr                 = "10.23.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = ["10.23.4.0/24", "10.23.5.0/24", "10.23.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
}

#resource "aws_cloud9_environment_ec2" "mongo-devl-cloud9" {
#    instance_type = "t2.micro"
#    name          = "mongo-cloud9-mnm"
#    subnet_id     = module.vpc.public_subnets.0
#}


resource "aws_security_group" "mongo-tunel-sg" {
  name        = "mongo-tunel-sg"
  description = "mongo-tunel-sg"
  vpc_id      = module.vpc.vpc_id

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
    Name = "mongo-tunel-sg"
  }
}

resource "aws_network_interface" "mongo-tunel-nic" {
  subnet_id       = module.vpc.public_subnets.0
  private_ips     = ["10.23.4.5"]
  security_groups = [aws_security_group.mongo-tunel-sg.id]
}

resource "aws_instance" "mongo-tunel-instance" {
  ami           = "ami-06602da18c878f98d"
  instance_type = "t2.micro"
  availability_zone = "eu-west-3a"
  key_name      = "mongo-tunel-kp"

  network_interface {
    network_interface_id = aws_network_interface.mongo-tunel-nic.id
    device_index         = 0
  }

  user_data = <<-EOF
                #!/bin/bash
                echo -e "[mongodb-org-4.0] \nname=MongoDB Repository\nbaseurl=https://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/4.0/x86_64/\ngpgcheck=1 \nenabled=1 \ngpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc" | sudo tee /etc/yum.repos.d/mongodb-org-4.0.repo
                wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
                echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
                sudo apt-get update
                sudo apt-get install -y mongodb-org
                wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem                
                EOF

  tags = {
    Name = "mongo-tunel"
  }
}

resource "aws_security_group" "mongo-cluster-sec-group" {
  name   = "mongo-sec-group"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.mongo-tunel-sg.id]
  }

  egress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups = [aws_security_group.mongo-tunel-sg.id]
  }

  tags = {
    Name = "mongo-cluster-sec-group"
  }
}

resource "aws_docdb_subnet_group" "mongodb-devl-subnet" {
  name       = "mongodb-devl-subnet"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "mongodb-devl-subnet"
  }
}

resource "aws_docdb_cluster" "mongodb-devl" {
  cluster_identifier      = "mongodb-devl"
  availability_zones      = data.aws_availability_zones.available.names 
  engine                  = "docdb"
  master_username         = "dogooddevl"
  master_password         = "DoG00dP3ople"
  backup_retention_period = 5
  preferred_backup_window = "03:00-05:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.mongo-cluster-sec-group.id]
  db_subnet_group_name    = aws_docdb_subnet_group.mongodb-devl-subnet.name
}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "mongodb-devl-${count.index}"
  cluster_identifier = aws_docdb_cluster.mongodb-devl.id
  instance_class     = "db.r5.large"
}
