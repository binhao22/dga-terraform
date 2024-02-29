# DB 서브넷 그룹 생성
resource "aws_db_subnet_group" "dga-subgroup" {
  name = "dga-subgroup"
  subnet_ids = [ var.db-subs[0], var.db-subs[1] ]

  tags = {
    "Name" = "dga-subgroup"
  }

}

# RDS for postgre DB 생성
resource "aws_db_instance" "dga-postgre" {
  # 오토스케일링 설정
  allocated_storage = 20
  max_allocated_storage = 50
  skip_final_snapshot = true
  # 자동 백업 주기 설정
  backup_retention_period = 7
  db_subnet_group_name = aws_db_subnet_group.dga-subgroup.name
  vpc_security_group_ids = [var.db-sg]
  engine = "postgres"
  engine_version = "14.11"
  instance_class = "db.m5.large"
  storage_type   = "gp3"
  identifier = "dga-postgre"
  # 유저 ID, Password 지정
  username = "muzzi"
  password = var.db-password
  # 허용 포트 설정
  port = "5432"
  # 다중AZ 설정
  multi_az = true
  # CloudWatch 로그 전송
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    "Name" = "dga-prostgre"
  }
}