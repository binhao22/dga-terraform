resource "aws_docdb_cluster" "dga-docdb" {
  cluster_identifier      = "dga-docdb"
  engine                  = "docdb"
  master_username         = "muzzi"
  master_password         = var.db-password
  skip_final_snapshot     = true
  db_subnet_group_name    = var.db-subgroup
  storage_type            = "standard"
  port                    = "27017"
  vpc_security_group_ids  = [ var.db-sg ]
}

resource "aws_docdb_cluster_instance" "dga-docdb-ins" {
  count              = 2
  identifier         = "dga-docdb-ins-${count.index}"
  cluster_identifier = aws_docdb_cluster.dga-docdb.id
  instance_class     = "db.r6g.large"
}