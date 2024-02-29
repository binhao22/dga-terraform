# ACM 인증서 ARN
output "cert-arn" {
  value = module.acm.acm_certificate_arn
}