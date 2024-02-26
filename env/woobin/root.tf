# VPC module
module "dga-vpc" {
  source = "./module/vpc"

  vpc_cidr = var.vpc_cidr
  # name     = var.name
  # tags     = var.tags
  # az_names = var.az_names
  # public_subnets  = var.public_subnets
  # private_subnets = var.private_subnets
}

# Security Group
module "dga-sg" {
  source = "./module/sg"
}


# test_create_ec2
resource "aws_instance" "woobin-test-ec2" {
  subnet_id  = module.dga-vpc.dga-pub-1-id
  ami           = "ami-0c76973fbe0ee100c"
  instance_type = "t2.nano"
  associate_public_ip_address = true
  vpc_security_group_ids = [module.dga-sg.dga-nlb-sg-id]

  tags = {
    Name = "woobin-test-ec2"
  }
}