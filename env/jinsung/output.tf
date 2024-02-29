# output "eks_cluster_endpoint" {
#     value = module.dga-eks.eks_cluster_endpoint
# } 
# output "eks_cluster_certificate_authority_data" {
#   value = module.dga-eks.eks_cluster_certificate_authority_data
# }
# output "token" {
#   value = module.dga-eks.token
# }
output "alb-id" {
  value = module.dga-eks.kubernetes_ingress_v1.alb
}