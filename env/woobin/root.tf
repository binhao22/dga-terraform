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
  dga-nlb-dns = module.dga-elb.dga-nlb-dns
  dga-nlb-id = module.dga-elb.dga-nlb-id
  cognito-arn = module.dga-cognito.cognito-arn
}

# Cognito
module "dga-cognito" {
  source = "./module/cognito"
  google_id = var.google_id
  google_secret = var.google_secret
}

# RDS
module "dga-rds" {
  source = "./module/rds"
  dga-keypair = var.dga-keypair
  db-subs = [module.dga-vpc.dga-pri-1-id, module.dga-vpc.dga-pri-2-id]
  db-sg = module.dga-sg.dga-pri-db-sg-id
  db-password = var.db-password
}

# Docdb
module "dga-docdb" {
  source = "./module/docdb"
  db-subgroup = module.dga-rds.db-subgroup
  db-password = var.db-password
  db-sg        = module.dga-sg.dga-pri-db-sg-id
}