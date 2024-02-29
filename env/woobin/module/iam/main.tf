# ACM 인증서 생성
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"
  # 요청할 도메인
  domain_name  = "*.${var.domain}"
  # 호스팅존 지정
  zone_id      = var.zone-id
  # 검증 방식
  validation_method = "DNS"
  subject_alternative_names = [
    "*.${var.domain}",
  ]
  # 검증을 기다린 후 모듈 종료, CloudFront 배포 전에 정상적으로 넘겨주기위함
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