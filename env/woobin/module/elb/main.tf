data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}

resource "aws_lb" "dga-nlb" {
  name               = "dga-nlb-prod"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [var.nlb-sg]
  subnets            = ["var.nlb-subs"]
  enable_deletion_protection = true

  tags = {
    name = "dga-nlb"
  }
}