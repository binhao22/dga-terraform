# Create a VPC
resource "aws_vpc" "dev-terraform" {
  cidr_block = var.vpc_cidr
}


