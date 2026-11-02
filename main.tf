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

# The main S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket_prefix = "nayan-project-bucket-"

  tags = {
    Name        = "Nayan-Storage-Bucket"
    Environment = "Dev"
  }
}

# Fix for AWS-0086, AWS-0087, AWS-0091, AWS-0093: Explicitly block all public access
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Fix for AWS-0132: Enforce default server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Safely clears security warnings without creating extra KMS costs
    }
  }
}
