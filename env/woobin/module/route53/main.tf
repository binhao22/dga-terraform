resource "aws_route53_zone" "hosted-zone" {
  name = var.domain
  force_destroy = true
}

resource "aws_route53_record" "root-domain" {
  zone_id = aws_route53_zone.hosted-zone.zone_id
  name = format("%s%s", "www.", var.domain)
  type = "A"

  alias {
    name = var.domain_name
    zone_id = var.hosted_zone_id
    evaluate_target_health = true
  }
}