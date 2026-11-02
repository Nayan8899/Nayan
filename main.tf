terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

# 1. Create a clean, dedicated VPC for your servers
resource "aws_vpc" "nayan_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "Nayan-VPC"
  }
}

# 2. Create a public subnet inside the new VPC
resource "aws_subnet" "nayan_subnet" {
  vpc_id                  = aws_vpc.nayan_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true # Automatically assigns public IPs to your EC2 instances

  tags = {
    Name = "Nayan-Public-Subnet"
  }
}

# 3. Create an Internet Gateway so your instances can talk to the internet
resource "aws_internet_gateway" "nayan_igw" {
  vpc_id = aws_vpc.nayan_vpc.id

  tags = {
    Name = "Nayan-IGW"
  }
}

# 4. Create a Routing Table to direct traffic through the Gateway
resource "aws_route_table" "nayan_rt" {
  vpc_id = aws_vpc.nayan_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nayan_igw.id
  }

  tags = {
    Name = "Nayan-Route-Table"
  }
}

# 5. Associate the route table with your subnet
resource "aws_route_table_association" "nayan_rta" {
  subnet_id      = aws_subnet.nayan_subnet.id
  route_table_id = aws_route_table.nayan_rt.id
}

# 6. Launch your two instances explicitly attached to the new subnet
resource "aws_instance" "mumbai_servers" {
  count         = 2
  ami           = "ami-0dee22c13ea7a9a67" # Official Ubuntu 24.04 AMI for ap-south-1
  instance_type = "t2.micro"
  
  # Links your instances to the explicit subnet we created above
  subnet_id     = aws_subnet.nayan_subnet.id

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "Nayan-Server-${count.index + 1}"
  }
}
