# DocumentDB 클러스터 생성
resource "aws_docdb_cluster" "dga-docdb" {
  cluster_identifier      = "dga-docdb"
  engine                  = "docdb"
  # 마스터 유저네임, 패스워드 설정
  master_username         = "muzzi"
  master_password         = var.db-password
  skip_final_snapshot     = true
  # 자동 백업 주기 설정
  backup_retention_period = 7
  # 서브넷 그룹 지정
  db_subnet_group_name    = var.db-subgroup
  storage_type            = "standard"
  # 특정 포트만 허용
  port                    = "27017"
  # DB 보안그룹 지정
  vpc_security_group_ids  = [ var.db-sg ]
  # CloudWatch 로그 전송
  enabled_cloudwatch_logs_exports = ["audit", "profiler"]
}

# DB 클러스터 인스턴스 생성
resource "aws_docdb_cluster_instance" "dga-docdb-ins" {
  count              = 2
  # 식별자 ID
  identifier         = "dga-docdb-ins-${count.index}"
  cluster_identifier = aws_docdb_cluster.dga-docdb.id
  instance_class     = "db.r6g.large"
}