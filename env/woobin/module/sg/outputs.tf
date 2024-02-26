output "dga-pub-sg-id" {
  value = aws_security_group.dga-pub-sg.id
}

output "dga-pri-sg-id" {
  value = aws_security_group.dga-pri-sg.id
}

output "dga-pri-db-sg-id" {
  value = aws_security_group.dga-pri-db-sg.id
}