terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# #
provider "helm" {
  kubernetes {
    host                   = module.dga-eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.dga-eks.eks_cluster_certificate_authority_data)
    #token                  = module.dga-eks.token
  }
}

provider "kubernetes" {
  host                   = module.dga-eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.dga-eks.eks_cluster_certificate_authority_data)
  #token                  = module.dga-eks.token
}