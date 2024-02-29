# Route53 호스팅존 생성
resource "aws_route53_zone" "hosted-zone" {
  name = var.domain
  # 레코드가 존재해도 강제 삭제 허용
  force_destroy = true
}

# Route53 레코드 생성
resource "aws_route53_record" "root-domain" {
  zone_id = aws_route53_zone.hosted-zone.zone_id
  # www.도메인 A 레코드
  name = format("%s%s", "www.", var.domain)
  type = "A"
  # CloudFront 에서 값을 받아와 별칭 연결
  alias {
    name = var.domain_name
    zone_id = var.hosted_zone_id
    evaluate_target_health = true
  }
}