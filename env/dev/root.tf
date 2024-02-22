# VPC module
module "dga-vpc" {
  source = "../../module/vpc"

  vpc_cidr = var.vpc_cidr
  # name     = var.name
  # tags     = var.tags
  # az_names = var.az_names
  # public_subnets  = var.public_subnets
  # private_subnets = var.private_subnets
}
#


## test_create_ec2
resource "aws_instance" "test_tf" {
  subnet_id  = module.dga-vpc.dga-pub-1_id
  ami           = "ami-0c76973fbe0ee100c"
  instance_type = "t2.nano"
  associate_public_ip_address = true

  tags = {
    Name = "test_tf"
  }
}