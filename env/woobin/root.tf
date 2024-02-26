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

# ELB
module "dga-elb" {
  source = "./module/elb"
  vpc-id = module.dga-vpc.dga-vpc-id
  nlb-subs = [module.dga-vpc.dga-pub-1-id, module.dga-vpc.dga-pub-2-id]
  nlb-sg = module.dga-sg.dga-pub-sg-id
}

# API Gateway
module "dga-apigw" {
  source = "./module/apigw"
  dga-nlb-id = module.dga-elb.dga-nlb-id
}


# test_create_ec2
resource "aws_instance" "woobin-test-ec2" {
  subnet_id  = module.dga-vpc.dga-pub-1-id
  ami           = "ami-0c76973fbe0ee100c"
  instance_type = "t2.nano"
  associate_public_ip_address = true
  vpc_security_group_ids = [module.dga-sg.dga-pub-sg-id]

  tags = {
    Name = "woobin-test-ec2"
  }
}