terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [ aws.acm ]
    }
  }
}

provider "aws" {
  region = var.region
}

# 기본 리전 외 별칭 지정, ACM 인증서를 위함
provider "aws" {
  alias = "acm"
  region = "us-east-1"
}