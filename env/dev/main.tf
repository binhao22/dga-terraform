# Env Setting
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider 
provider "aws" {
  region = var.region
}

# VPC modules
module "vpc" {
  source = ".../module/vpc"
  vpc_cidr = var.vpc_cidr
}