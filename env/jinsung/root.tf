data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}

## test_create_ec2
module "dga-eks" {
  source = "./module/eks"
  vpc_cidr = var.vpc_cidr
}