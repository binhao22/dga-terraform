
# # #  EKS module

module "dga-eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.26.6"
  cluster_name    = "dga-cluster-test"
  cluster_version = "1.29"
  # k8s version

  cluster_security_group_id = var.dga-pri-sg-id
  # node_security_group_id = var.dga-pub-sg-id
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

# # # provider

data "aws_eks_cluster_auth" "this" {
  name = "dga-cluster-test"
}


provider "helm" {
  kubernetes {
    host                   = module.dga-eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.dga-eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubernetes" {
  host                   = module.dga-eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.dga-eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# # #

locals {
  lb_controller_iam_role_name        = "dga-eks-aws-lb-ctrl1"
  lb_controller_service_account_name = "aws-load-balancer-controller"
}
# 재설정 변수 

module "lb_controller_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"

  create_role = true

  role_name        = local.lb_controller_iam_role_name
  role_path        = "/"
  role_description = "Used by AWS Load Balancer Controller for EKS"

  role_permissions_boundary_arn = ""

  provider_url = replace(module.dga-eks.cluster_oidc_issuer_url, "https://", "")
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:${local.lb_controller_service_account_name}"
  ]
  oidc_fully_qualified_audiences = [
    "sts.amazonaws.com"
  ]
}

data "http" "iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json"
}

resource "aws_iam_role_policy" "controller" {
  name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  policy      = data.http.iam_policy.body
  role        = module.lb_controller_role.iam_role_name
}

resource "helm_release" "release" {
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  dynamic "set" {
    for_each = {
      "clusterName"                                               = "dga-cluster-test"
      "serviceAccount.create"                                     = "true"
      "serviceAccount.name"                                       = local.lb_controller_service_account_name
      "region"                                                    = "ap-northeast-2"
      "vpcId"                                                     = var.dga-vpc-id
      "image.repository"                                          = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = "arn:aws:iam::420615923610:role/dga-eks-aws-lb-ctrl1"
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

# 배포에 사용할 namespace 지정
locals {
  ns_admin      = "admin"
  ns_board = "board"
  ns_leaderboard = "leaderboard"
  ns_user = "user"
  ns_search = "search"
  ns_myplan = "myplan"
}

# # # namespace

resource "kubernetes_namespace" "board" {
  metadata {
    name = "board"
  }
}
resource "kubernetes_namespace" "user" {
  metadata {
    name = "user"
  }
}
resource "kubernetes_namespace" "leaderboard" {
  metadata {
    name = "leaderboard"
  }
}
resource "kubernetes_namespace" "myplan" {
  metadata {
    name = "myplan"
  }
}
resource "kubernetes_namespace" "search" {
  metadata {
    name = "search"
  }
}
resource "kubernetes_namespace" "admin" {
  metadata {
    name = "admin"
  }
}

# # # ingress 배포

resource "kubernetes_ingress_v1" "alb" {
  metadata {
    name = "user-ingress"
    namespace = local.ns_user
    
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" = "dga-alb-test"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "dga-alb-group"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/users/testget"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = "user-svc"
              port {
                number = 80
              }
            }
          }
          path = "/users"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "alb2" {
  metadata {
    name = "admin-ingress"
    namespace = local.ns_admin
    
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" = "dga-alb-test"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "dga-alb-group"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/admins"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = "admin-svc"
              port {
                number = 80
              }
            }
          }
          path = "/admins"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "alb3" {
  metadata {
    name = "board-ingress"
    namespace = local.ns_board
    
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" = "dga-alb-test"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "dga-alb-group"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/boards/list"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = "board-svc"
              port {
                number = 80
              }
            }
          }
          path = "/boards"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "alb4" {
  metadata {
    name = "leaderboard-ingress"
    namespace = local.ns_leaderboard
    
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" = "dga-alb-test"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "dga-alb-group"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/leaderboards"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = "leaderboard-svc"
              port {
                number = 80
              }
            }
          }
          path = "/leaderboards"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "alb5" {
  metadata {
    name = "myplan-ingress"
    namespace = local.ns_myplan
    
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" = "dga-alb-test"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "dga-alb-group"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/myplans"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = "myplan-svc"
              port {
                number = 80
              }
            }
          }
          path = "/myplans"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "alb6" {
  metadata {
    name = "search-ingress"
    namespace = local.ns_search
    
    annotations = {
      "alb.ingress.kubernetes.io/load-balancer-name" = "dga-alb-test"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = "dga-alb-group"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/searches"
    }
  }
  spec {
    ingress_class_name = "alb"
    rule {
      http {
        path {
          backend {
            service {
              name = "search-svc"
              port {
                number = 80
              }
            }
          }
          path = "/searches"
        }
      }
    }
  }
}

# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }

# resource "helm_release" "argocd" {
#   name       = "admin"
#   chart      = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
#   namespace  = "argocd"
# }