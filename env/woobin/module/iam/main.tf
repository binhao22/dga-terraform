resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain
  validation_method = "EMAIL"

  tags = {
    Name = "dga-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}