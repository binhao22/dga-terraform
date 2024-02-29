# 퍼블릭 보안그룹 생성
resource "aws_security_group" "dga-pub-sg" {
  vpc_id = var.vpc-id
  name = "dga-pub-sg"
  description = "dga-pub-sg"
  tags = {
    Name = "dga-pub-sg"
  }
}

# 프라이빗 보안그룹 생성
resource "aws_security_group" "dga-pri-sg" {
  vpc_id = var.vpc-id
  name = "dga-pri-sg"
  description = "dga-pri-sg"
  tags = {
    Name = "dga-pri-sg"
  }
}

# 프라이빗 DB 보안그룹 생성
resource "aws_security_group" "dga-pri-db-sg" {
  vpc_id = var.vpc-id
  name = "dga-pri-db-sg"
  description = "dga-pri-db-sg"
  tags = {
    Name = "dga-pri-db-sg"
  }
}

# 퍼블릭 보안그룹 http 인그리스 규칙
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
# 퍼블릭 보안그룹 https 인그리스 규칙
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
# 퍼블릭 보안그룹 ssh 인그리스 규칙
resource "aws_security_group_rule" "dga-pub-ssh-ingress" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.dga-pub-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
# 퍼블릭 보안그룹 egress 규칙
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

# 프라이빗 보안그룹 http 인그리스 규칙
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
# 프라이빗 보안그룹 https 인그리스 규칙
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
# 프라이빗 보안그룹 ssh 인그리스 규칙
resource "aws_security_group_rule" "dga-pri-ssh-ingress" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "TCP"
  source_security_group_id = aws_security_group.dga-pub-sg.id
  security_group_id = aws_security_group.dga-pri-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
# 프라이빗 보안그룹 egress 규칙
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

# 프라이빗 DB 보안그룹 rds 인그리스 규칙
resource "aws_security_group_rule" "dga-pri-db-rds-ingress" {
  type = "ingress"
  from_port = 5432
  to_port = 5432
  protocol = "TCP"
  source_security_group_id = aws_security_group.dga-pri-sg.id
  security_group_id = aws_security_group.dga-pri-db-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
# 프라이빗 DB 보안그룹 docdb 인그리스 규칙
resource "aws_security_group_rule" "dga-pri-db-dynamo-ingress" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "TCP"
  source_security_group_id = aws_security_group.dga-pri-sg.id
  security_group_id = aws_security_group.dga-pri-db-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
# 프라이빗 DB 보안그룹 egress 규칙
resource "aws_security_group_rule" "dga-pri-db-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.dga-pri-db-sg.id
  lifecycle {
    create_before_destroy = true
  }
}
