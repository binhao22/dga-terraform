# # 다른 워크스페이스의 variables 값 사용을 위해
# data "tfe_outputs" "woobin" {
#   organization = "DGA-PROJECT"
#   workspace = "woobin"
# }

# # locals {
#   dga-vpc-id = data.tfe_outputs.woobin.values.dga-vpc-id
#   dga-pub-1-id = data.tfe_outputs.woobin.values.dga-pub-1-id
#   dga-pub-2-id = data.tfe_outputs.woobin.values.dga-pub-2-id
#   dga-pri-1-id = data.tfe_outputs.woobin.values.dga-pri-1-id
#   dga-pri-2-id = data.tfe_outputs.woobin.dga-pri-2-id
# # }

module "dga-eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.6"
  cluster_name    = "dga-cluster-test"
  cluster_version = "1.25"
  # k8s version

  cluster_security_group_id = var.dga-pri-sg-id
  # security group 설정

  vpc_id          = var.dga-vpc-id
  # vpc id

  subnet_ids = [
    var.dga-pri-1-id,
    var.dga-pri-2-id
  ]
  # 클러스터의 subnet 설정

  eks_managed_node_groups = {
    dga_node_group = {
      min_size       = 2
      max_size       = 4
      desired_size   = 3
      instance_types = ["m6i.large"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

  cluster_endpoint_private_access = true
  # cluster를 private sub에 만듬
}

# resource "aws_security_group_rule" "eks_cluster_add_access" {
#   security_group_id = module.eks.cluster_security_group_id
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["10.0.0.0/16"]
# }

# resource "aws_security_group_rule" "eks_node_add_access" {
#   security_group_id = module.eks.node_security_group_id
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks       = ["10.0.0.0/16"]
# }