# 1. Define AWS Provider targeting the Mumbai Region
provider "aws" {
  region = "ap-south-1"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# 2. Query available Availability Zones in Mumbai dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# 3. Create a Custom VPC with 3 Public Subnets
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "mumbai-public-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  map_public_ip_on_launch = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# 4. Create the Amazon EKS Cluster mapped to the Public Subnets
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "mumbai-public-eks"
  kubernetes_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  endpoint_public_access = true

  # Maps local AWS profile directly to cluster Admin permissions
  enable_cluster_creator_admin_permissions = true

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
