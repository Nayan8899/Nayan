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

# 1. Create a Customer Managed KMS Key for absolute compliance
resource "aws_kms_key" "mykey" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true # Satisfies best-practice security frameworks
}

# 2. The main S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket_prefix = "nayan-project-bucket-"

  tags = {
    Name        = "Nayan-Storage-Bucket"
    Environment = "Dev"
  }
}

# 3. Block all public access
resource "aws_s3_bucket_public_access_block" "public_block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Enforce server-side encryption via our Customer Managed Key (Fixes AWS-0132)
resource "aws_s3_bucket_server_side_encryption_configuration" "sse_config" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
