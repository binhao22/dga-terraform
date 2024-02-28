# provider "kubernetes" {
#   host                   = module.dga-eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.dga-eks.cluster_certificate_authority_data)
#   token                  = data.aws_eks_cluster_auth.eks.token
# }
# # Allow Helm to access k8s
# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#     token                  = data.aws_eks_cluster_auth.eks.token
#   }
# }

# data "aws_caller_identity" "current" {} # ${data.aws_caller_identity.current.account_id}
# data "aws_eks_cluster_auth" "eks" {name = module.dga-eks.cluster_name}

# # #  EKS module

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

module "load_balancer_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "dga-test-lb-controller-irsa-role" # test 이름
  attach_load_balancer_controller_policy = true 
  
  oidc_providers = {
    main = {
      provider_arn               = module.dga-eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  # tags = local.tags
}

module "load_balancer_controller_targetgroup_binding_only_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "dga-test-lb-controller-tg-binding-only-irsa-role" # test 이름
  attach_load_balancer_controller_targetgroup_binding_only_policy = true  

  oidc_providers = {
    main = {
      provider_arn               = module.dga-eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  # tags = local.tags
}

resource "kubernetes_service_account" "aws-load-balancer-controller" {
  metadata {
    name        = "aws-load-balancer-controller"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.load_balancer_controller_irsa_role.iam_role_arn 
    }

    labels = {
      "app.kubernetes.io/component" = "controller"
      "app.kubernetes.io/name" = "aws-load-balancer-controller"
    }

  }

  depends_on = [module.load_balancer_controller_irsa_role]
}


resource "kubernetes_service_account" "external-dns" {
  metadata {
    name        = "external-dns"
    namespace   = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.external_dns_irsa_role.iam_role_arn
    }
  }

  depends_on = [module.external_dns_irsa_role]
}

module "external_dns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                     = "dga-test-externaldns-irsa-role" # test 이름
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = [local.external_dns_arn]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }

  tags = local.tags
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # HELM
# # # # # # # # # # # # # # # # # # # # # # # # # # #

# https://github.com/GSA/terraform-kubernetes-aws-load-balancer-controller/blob/main/main.tf
# https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.5/
resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  set {
    name = "clusterName"
    value = "dga-cluster-test"
  }
  set {
    name = "serviceAccount.create"
    value = false
  }
  set {
    name = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  # 위와 동일
  # dynamic "set" {
  #   for_each = {
  #     "clusterName" = module.eks.cluster_name
  #   }
  # }
  # depends_on = [kubernetes_service_account.aws-load-balancer-controller]
}

# https://tech.polyconseil.fr/external-dns-helm-terraform.html
# parameter https://github.com/kubernetes-sigs/external-dns/tree/master/charts/external-dns
resource "helm_release" "external_dns" {
  name       = "external-dns"
  namespace  = "kube-system"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  wait       = false
  set {
    name = "provider"
    value = "aws"
  }
  set {
    name = "serviceAccount.create"
    value = false
  }
  set {
    name = "serviceAccount.name"
    value = "external-dns"
  }
  set {
    name  = "policy"
    value = "sync"
  }     
}