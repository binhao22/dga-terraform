# CloudFront 생성
resource "aws_cloudfront_distribution" "cdn" {
  # S3 오리진 생성
  origin {
    origin_id   = "dga-s3"
    # S3버킷네임.s3-website.리전.amazonaws.com
    domain_name = var.s3-id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  # API 게이트웨이 오리진 생성
  origin {
    origin_id   = "dga-apigw"
    # APIGW_id.execute-api.리전.amazonaws.com
    domain_name = "${var.apigw-id}.execute-api.${var.region}.amazonaws.com"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }
  # CNAME 설정, Route53 A 레코드와 연결
  aliases = ["www.${var.domain}"]
  enabled             = true

  # 라우팅 Behavior 기본값
  default_cache_behavior {
    target_origin_id = "dga-s3"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    # Caching Optimized AWS Managed
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    # https 리다이렉션
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  # 라우팅 Behavior 우선순위
  ordered_cache_behavior {
    target_origin_id = "dga-apigw"
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    # Caching Disabled AWS Managed
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }
  # 지역 기반 리다이렉션 지정 안함
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  # acm 인증서 지정
  viewer_certificate {
    acm_certificate_arn = var.cert-arn
    cloudfront_default_certificate = true
    ssl_support_method = "sni-only"
  }
}