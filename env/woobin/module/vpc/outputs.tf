# vpc id
output "dga-vpc-id" {
  value = aws_vpc.dga-vpc.id
}
# 퍼블릭 서브넷 id
output "dga-pub-1-id" {
  value       = aws_subnet.dga-pub-1.id
}
output "dga-pub-2-id" {
  value       = aws_subnet.dga-pub-2.id
}
# 프라이빗 서브넷 id
output "dga-pri-1-id" {
  value       = aws_subnet.dga-pri-1.id
}
output "dga-pri-2-id" {
  value       = aws_subnet.dga-pri-2.id
}