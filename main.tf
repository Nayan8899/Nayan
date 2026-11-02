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
  region = "ap-south-1" # Mumbai Region
}

resource "aws_s3_bucket" "my_bucket" {
  # S3 bucket names must be unique worldwide. 
  # Using 'bucket_prefix' lets AWS add random numbers to the end so it never fails.
  bucket_prefix = "nayan-project-bucket-"

  tags = {
    Name        = "Nayan-Storage-Bucket"
    Environment = "Dev"
  }
}
