# CloudFront 호스팅존
output "hosted_zone_id" {
  value = aws_cloudfront_distribution.cdn.hosted_zone_id
}
# CloudFront 도메인네임
output "domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}