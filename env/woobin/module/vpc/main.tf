# VPC 생성
resource "aws_vpc" "dga-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "dga-vpc"
  }
}


# NACL 생성
resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.dga-vpc.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "dga-nacl"
  }
}


# 퍼블릭 서브넷 생성
resource "aws_subnet" "dga-pub-1" {
  vpc_id            = aws_vpc.dga-vpc.id
  cidr_block        = "10.0.0.0/20"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "dga-pub-1"
  }
}

resource "aws_subnet" "dga-pub-2" {
  vpc_id            = aws_vpc.dga-vpc.id
  cidr_block        = "10.0.16.0/20"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "dga-pub-2"
  }
}


## 프라이빗 서브넷 생성
resource "aws_subnet" "dga-pri-1" {
  vpc_id            = aws_vpc.dga-vpc.id
  cidr_block        = "10.0.128.0/20"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "dga-pri-1"
  }
}

resource "aws_subnet" "dga-pri-2" {
  vpc_id            = aws_vpc.dga-vpc.id
  cidr_block        = "10.0.144.0/20"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "dga-pri-2"
  }
}


# NATGW 탄력적 주소 생성
resource "aws_eip" "dga-eip-ngw" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "dga-eip-ngw"
  }
}


# 인터넷 게이트웨이 생성
resource "aws_internet_gateway" "dga-igw" {
  vpc_id = aws_vpc.dga-vpc.id

  tags = {
    Name = "dga-igw"
  }
}


# NAT 게이트웨이 생성
resource "aws_nat_gateway" "dga-ngw" {
  allocation_id = aws_eip.dga-eip-ngw.id
  subnet_id     = aws_subnet.dga-pub-1.id

  tags = {
    Name = "dga-ngw"
  }

  # depends_on = [aws_internet_gateway.dga-eip-ngw]
}


# 퍼블릭 라우팅 테이블 생성
resource "aws_route_table" "dga-rtb-pub" {
  vpc_id = aws_vpc.dga-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dga-igw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "dga-rtb-pub"
  }

  # depends_on = [aws_internet_gateway.dga-igw]
}


# 프라이빗 라우팅 테이블 생성
resource "aws_route_table" "dga-rtb-pri" {
  vpc_id = aws_vpc.dga-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dga-ngw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "dga-rtb-pri"
  }

  # depends_on = [aws_internet_gateway.dga-ngw]
}


# 라우팅 테이블 - 서브넷 연결
resource "aws_route_table_association" "dga-rtb-association-pub-1" {
  subnet_id      = aws_subnet.dga-pub-1.id
  route_table_id = aws_route_table.dga-rtb-pub.id
}

resource "aws_route_table_association" "dga-rtb-association-pub-2" {
  subnet_id      = aws_subnet.dga-pub-2.id
  route_table_id = aws_route_table.dga-rtb-pub.id
}

resource "aws_route_table_association" "dga-rtb-association-pri-1" {
  subnet_id      = aws_subnet.dga-pri-1.id
  route_table_id = aws_route_table.dga-rtb-pri.id
}

resource "aws_route_table_association" "dga-rtb-association-pri-2" {
  subnet_id      = aws_subnet.dga-pri-2.id
  route_table_id = aws_route_table.dga-rtb-pri.id
}