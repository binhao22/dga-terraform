data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}

# test_create_ec2
module "dga-eks" {
  source = "./module/eks"
  dga-vpc-id = data.tfe_outputs.woobin.values.dga-vpc-id
  dga-pri-1-id = data.tfe_outputs.woobin.values.dga-pri-1-id
  dga-pri-2-id = data.tfe_outputs.woobin.values.dga-pri-2-id
  dga-pri-sg-id = data.tfe_outputs.woobin.values.dga-pri-sg-id
}