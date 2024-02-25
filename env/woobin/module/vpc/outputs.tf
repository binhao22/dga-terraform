output "dga-vpc-id" {
  value = aws_vpc.dga-vpc.id
}

output "dga-pub-1-id" {
  value       = aws_subnet.dga-pub-1.id
}

output "dga-pub-2-id" {
  value       = aws_subnet.dga-pub-2.id
}

output "dga-pri-1-id" {
  value       = aws_subnet.dga-pub-1.id
}

output "dga-pri-2-id" {
  value       = aws_subnet.dga-pub-2.id
}