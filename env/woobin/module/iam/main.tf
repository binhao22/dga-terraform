resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain

  tags = {
    Name = "dga-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}