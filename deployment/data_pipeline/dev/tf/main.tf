
data "aws_ssm_parameter" "postgres_username" {
  name = "AIRFLOW_POSTGRES_USERNAME"
}

data "aws_ssm_parameter" "postgres_password" {
  name = "AIRFLOW_POSTGRES_PASSWORD"
}

locals {
  athena_workgroups = [
    yamldecode(file("../cfg/test.yml"))
  ]
}
module "airflow_aws_resources" {
  source                       = "../../tmp_modules"
  resource_prefix = local.resource_prefix
  vpc_id                       = data.terraform_remote_state.networking.outputs.vpc_id
  env                          = var.env
  private_bucket               = var.private_bucket
  private_subnets_ids          = data.terraform_remote_state.networking.outputs.private_subnets
  private_subnets_cidr_blocks  = data.terraform_remote_state.networking.outputs.private_subnets_cidr_blocks

  create_airflow_instance = true
  create_airflow_instance_sg = true
  create_airflow_db = true
  create_airflow_db_sg = true
  airflow_instance_ssm_access = true

  airflow_instance_ami              = "ami-0841edc20334f9287"
  airflow_instance_type        = "t2.micro"

  airflow_db_instance_class = "db.t2.micro"
  airflow_db_allocated_storage = 5
  airflow_db_name              = "${local.resource_prefix}-airflow-meta-db"
  airflow_db_username          = data.aws_ssm_parameter.postgres_username.value
  airflow_db_password          = data.aws_ssm_parameter.postgres_password.value
  # glue_jobs = local.glue_jobs
  # glue_crawlers = local.glue_crawlers
  # athena_workgroups = local.athena_workgroups
  # athena_queries = local.athena_queries
  # athena_databases = local.athena_databases
  # ec2_instances = local.ec2_instances
  # ec2_instances_security_groups = local.ec2_instances_security_groups
  # rds_dbs = local.rds_dbs
  # rds_dbs_security_groups = local.rds_dbs_security_groups
}


