data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}

# 퍼블릭 보안그룹
resource "aws_security_group" "dga-pub-sg" {
  vpc_id = data.tfe_outputs.woobin.values.dga-vpc-id
  name = "dga-pub-sg"
  description = "dga-pub-sg"
  tags = {
    Name = "dga-pub-sg"
  }
}

# 프라이빗 보안그룹
resource "aws_security_group" "dga-pri-sg" {
  vpc_id = data.tfe_outputs.woobin.values.dga-vpc-id
  name = "dga-pri-sg"
  description = "dga-pri-sg"
  tags = {
    Name = "dga-pri-sg"
  }
}

# 퍼블릭 보안그룹 규칙
resource "aws_security_group_rule" "dga-pub-http-ingress" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.dga-pub-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "dga-pub-https-ingress" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.dga-pub-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "dga-pub-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.dga-pub-sg.id
  lifecycle {
    create_before_destroy = true
  }
}

# 프라이빗 보안그룹 규칙
resource "aws_security_group_rule" "dga-pri-http-ingress" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "TCP"
  source_security_group_id = aws_security_group.dga-pub-sg.id
  security_group_id = aws_security_group.dga-pri-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "dga-pri-https-ingress" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "TCP"
  source_security_group_id = aws_security_group.dga-pub-sg.id
  security_group_id = aws_security_group.dga-pri-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group_rule" "dga-pri-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.dga-pri-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
