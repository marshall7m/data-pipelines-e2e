resource "aws_db_subnet_group" "rds_dbs_subnetgroup" {
  for_each = {for group in var.rds_dbs_subnet_group: group.name => group}
  name        = each.key
  description = each.value.description
  subnet_ids  = each.value.subnet_ids
}

resource "aws_db_instance" "rds_dbs" {
  for_each = {for db in var.rds_dbs: db.name => db}
  identifier                = each.value.identifier
  allocated_storage         = each.value.allocated_storage
  engine                    = lookup(each.value, "db_engine", "postgres")
  engine_version            = lookup(each.value, "db_engine_version", "")
  instance_class            = each.value.instance_class
  name                      = each.value.name
  username                  = each.value.username
  password                  = each.value.password
  storage_type              = lookup(each.value, "storage_type", "gp2")
  backup_retention_period   = lookup(each.value, "backup_retention_period", 14)
  multi_az                  = lookup(each.value, "multi_az", true)
  publicly_accessible       = lookup(each.value, "publicly_accessible", false)
  apply_immediately         = lookup(each.value, "apply_immediately", true)
  db_subnet_group_name      = each.value.db_subnet_group_name
  final_snapshot_identifier = lookup(each.value, "final_snapshot_identifier", "${each.value.identifier}-${each.value.name}-final-snapshot") 
  skip_final_snapshot       = lookup(each.value, "skip_final_snapshot", false)
  vpc_security_group_ids      = lookup(each.value, "vpc_security_group_ids", [for name in each.value.vpc_security_groups_names: aws_security_group.rds_dbs[name].id])
  port                      = lookup(each.value, "port", "5432")
}
resource "aws_security_group" "rds_dbs" {
  for_each = {for group in var.rds_dbs_security_groups: group.name => group}
  name        = each.key
  description = lookup(each.value, "description", null)
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = {for rule in each.value.ingress: "_" => rule}
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  
  dynamic "egress" {
    for_each = {for rule in each.value.egress: "_" => rule}
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}