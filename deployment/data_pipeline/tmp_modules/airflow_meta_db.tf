resource "aws_db_subnet_group" "airflow_subnetgroup" {
  name        = var.db_subnet_group_name
  description = "airflow meta-db subnet group"
  subnet_ids  = var.private_subnet_ids
}

resource "aws_db_instance" "airflow_meta_db" {
  identifier                = var.indentifier
  allocated_storage         = var.allocated_storage
  engine                    = var.db_engine
  engine_version            = var.db_engine_version
  instance_class            = var.instance_class
  name                      = var.db_name
  username                  = var.db_username
  password                  = var.db_password
  storage_type              = var.storage_type
  backup_retention_period   = var.backup_retention_period
  multi_az                  = var.multi_az
  publicly_accessible       = var.publicly_accessible
  apply_immediately         = var.apply_immediately
  db_subnet_group_name      = var.db_subnet_group_name
  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot       = var.skip_final_snapshot
  vpc_security_group_ids    = var.vpc_security_group_ids
  port                      = var.db_port
}