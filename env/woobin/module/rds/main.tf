# resource "aws_key_pair" "dga-keypair" {
# 	key_name = dga-keypair
#   public_key = var.dga-keypair
# }

resource "aws_db_subnet_group" "dga-subgroup" {
  name = "dga-subgroup"
  subnet_ids = [ var.db-subs[0], var.db-subs[1] ]

  tags = {
    "Name" = "dga-subgroup"
  }

}

resource "aws_db_instance" "dga-postgre" {
  allocated_storage = 20
  max_allocated_storage = 50
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.dga-subgroup.name
  vpc_security_group_ids = [var.db-sg]
  engine = "postgres"
  engine_version = "14.11"
  instance_class = "db.m5.large"
  storage_type   = "gp3"
  identifier = "dga-postgre"
  username = "muzzi"
  password = var.db-password
  port = "5432"
  multi_az = true
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    "Name" = "dga-prostgre"
  }
}