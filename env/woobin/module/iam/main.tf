module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name  = var.domain
  zone_id      = var.zone-id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${my-domain.com}",
  ]

  wait_for_validation = true

  tags = {
    Name = "acm"
  }
}



# resource "aws_acm_certificate" "cert" {
#   domain_name       = "*.${var.domain}"
#   validation_method = "DNS"

#   tags = {
#     Name = "dga-cert"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_acm_certificate_validation" "validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [var.fqdn]
# }