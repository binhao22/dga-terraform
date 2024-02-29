# nlb 생성
resource "aws_lb" "dga-nlb" {
  name               = "dga-nlb-prod"
  # 퍼블릭
  internal           = false
  load_balancer_type = "network"
  # SG, Subnet 지정
  security_groups    = [var.nlb-sg]
  subnets            = [var.nlb-subs[0], var.nlb-subs[1]]
  # 삭제 방지 해제
  enable_deletion_protection = false

  tags = {
    name = "dga-nlb"
  }
}

# nlb 타겟그룹 생성
resource "aws_lb_target_group" "dga-nlb-tg" {
  name        = "dga-nlb-tg"
  # 타겟그룹 ALB 지정
  target_type = "alb"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc-id

  # 헬스체크 설정
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  } 

  tags = {
    name = "dga-nlb-tg"
  }
}

# nlb 타겟그룹 연결
/*
resource "aws_lb_target_group_attachment" "dga-nlb-tg-attachment" {
  target_group_arn = aws_lb_target_group.dga-nlb-tg.arn
  # EKS 에서 생성된 ALB 연결
  target_id        = aws_lb.eks-alb.id
  port             = 80

  tags = {
    name = "dga-nlb-tg-attachment"
  }
}
*/

# nlb 리스너 생성
resource "aws_lb_listener" "dga-nlb-listener" {
  load_balancer_arn = aws_lb.dga-nlb.arn
  port = 80
  protocol = "TCP"
  # 기본 작업
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dga-nlb-tg.arn
  }

  tags = {
    name = "dga-nlb-listener"
  }
}