output "eks_cluster_endpoint" {
    value = module.dga-eks.cluster_endpoint
} 
output "eks_cluster_certificate_authority_data" {
  value = module.dga-eks.cluster_certificate_authority_data
}