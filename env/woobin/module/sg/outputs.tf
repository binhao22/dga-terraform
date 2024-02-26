output "dga-nlb-sg-id" {
  value = aws_security_group.dga-nlb-sg.id
}

output "dga-eks-alb-sg-id" {
  value = aws_security_group.dga-eks-alb-sg.id
}