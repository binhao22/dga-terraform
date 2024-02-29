# nlb 엔드포인트
output "dga-nlb-dns" {
    value = aws_lb.dga-nlb.dns_name
}
# nlb ID
output "dga-nlb-id" {
    value = aws_lb.dga-nlb.id
}