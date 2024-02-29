resource "aws_cloudfront_distribution" "cdn" {
  origin {
    origin_id   = "dga-s3"
    domain_name = var.s3-id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  origin {
    origin_id   = "dga-apigw"
    domain_name = "${var.apigw-id}.execute-api.${var.region}.amazonaws.com"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  aliases = ["www.${var.domain}"]

  enabled             = true

  default_cache_behavior {
    target_origin_id = "dga-s3"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id  = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # Caching Optimized AWS Managed

    # forwarded_values {
    #   query_string = false
    #   cookies {S
    #     forward = "none"
    #   }
    # }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  ordered_cache_behavior {
    target_origin_id = "dga-apigw"
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"  # Caching Disabled AWS Managed

    # forwarded_values {
    #   query_string = false
    #   cookies {
    #     forward = "none"
    #   }
    # }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.cert-arn
    cloudfront_default_certificate = true
    ssl_support_method = "sni-only"
  }
}