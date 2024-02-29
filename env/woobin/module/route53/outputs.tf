# Route53 호스팅존 id
output "zone-id" {
  value = aws_route53_zone.hosted-zone.zone_id
}