# DB 서브넷 그룹
output "db-subgroup" {
  value = aws_db_subnet_group.dga-subgroup.name
}