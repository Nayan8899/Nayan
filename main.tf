provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "mumbai_servers" {
  count         = 2
  ami           = "ami-0dee22c13ea7a9a67" # Hardcoded official Ubuntu 24.04 AMI for ap-south-1 (Mumbai)
  instance_type = "t2.micro"

  # Satisfies Trivy security rule AWS-0028
  metadata_options {
    http_tokens = "required"
  }

  # FIX: Satisfies Trivy security rule AWS-0131
  root_block_device {
    encrypted             = true
    volume_type           = "gp3"
    delete_on_termination = true
  }

  tags = {
    Name = "Nayan-Server-${count.index + 1}"
  }
}
