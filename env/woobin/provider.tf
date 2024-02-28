terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [ aws.alternate ]
    }
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias = "acm"
  region = "us-east-1"
}