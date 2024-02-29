# 퍼블릿 보안그룹 id
output "dga-pub-sg-id" {
  value = aws_security_group.dga-pub-sg.id
}
# 프라이빗 보안그룹 id
output "dga-pri-sg-id" {
  value = aws_security_group.dga-pri-sg.id
}
# 프라이빗 DB 보안그룹 id
output "dga-pri-db-sg-id" {
  value = aws_security_group.dga-pri-db-sg.id
}