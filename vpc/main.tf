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

# Create a VPC
resource "aws_vpc" "dev-terraform" {
  cidr_block = "10.0.0.0/16"
}


