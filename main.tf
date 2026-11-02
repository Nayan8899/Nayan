terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configures the provider for the Mumbai region
provider "aws" {
  region = "ap-south-1"
}

# Fetches the latest official Ubuntu 24.04 LTS AMI in Mumbai
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical's official AWS Account ID
}

# Creates two EC2 Instances
resource "aws_instance" "mumbai_servers" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # Free-tier eligible size

  tags = {
    Name = "Nayan-Server-${count.index + 1}"
  }
}
