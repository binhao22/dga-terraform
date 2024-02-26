# 다른 워크스페이스의 variables 값 사용을 위해
data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}

locals {
  dga-vpc-id = data.tfe_outputs.woobin.values.dga-vpc-id
  dga-pub-1-id = data.tfe_outputs.woobin.values.dga-pub-1-id
  dga-pub-2-id = data.tfe_outputs.woobin.values.dga-pub-2-id
  dga-pri-1-id = data.tfe_outputs.woobin.values.dga-pri-1-id
  dga-pri-2-id = data.tfe_outputs.woobin.dga-pri-2-id
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.6"
  cluster_name    = "practice-cluster"
  cluster_version = "1.25"
  vpc_id          = local.dga-vpc-id
  subnet_ids = [
    local.dga-pub-1-id,
    local.dga-pub-2-id,
    local.dga-pri-1-id,
    local.dga-pri-2-id
  ]
  eks_managed_node_groups = {
    default_node_group = {
      min_size       = 2
      max_size       = 4
      desired_size   = 3
      instance_types = ["m6i.large"]
    }
  }

  cluster_security_group_id = data.tfe_outputs.woobin.values.dga-pri-sg-id

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
  cluster_endpoint_private_access = true
}