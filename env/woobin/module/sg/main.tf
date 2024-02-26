data "tfe_outputs" "woobin" {
  organization = "DGA-PROJECT"
  workspace = "woobin"
}

# nlb 보안그룹
resource "aws_security_group" "dga-nlb-sg" {
  vpc_id = data.tfe_outputs.woobin.values.dga-vpc-id
  name = "dga-nlb-sg"
  description = "dga-nlb-sg"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dga-nlb-sg"
  }
}

# eks-alb 보안그룹
resource "aws_security_group" "dga-eks-alb-sg" {
  vpc_id = data.tfe_outputs.woobin.values.dga-vpc-id
  name = "dga-eks-alb-sg"
  description = "dga-eks-alb-sg"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    source_security_group_id = aws_security_group.dga-nlb-sg.id
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    source_security_group_id = aws_security_group.dga-nlb-sg.id
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dga-eks-alb-sg"
  }
}