
data "aws_ssm_parameter" "postgres_username" {
  name = "${local.resource_prefix}-postgres-username"
  with_decryption = true
}

data "aws_ssm_parameter" "postgres_password" {
  name = "${local.resource_prefix}-postgres-password"
  with_decryption = true
}

# data "aws_ssm_parameter" "ssh_cidr" {
#   name = "AIRFLOW_EC2_SSH_IPS"
# }

module "sparkify_analytics" {
  source    = "./sparkify_analytics"
  athena_db = module.sparkify_etl.glue_catalog_db
  env       = var.env
}

module "sparkify_etl" {
  source = "./sparkify_etl"
  env    = var.env
}

module "terraform_aws_airflow" {
  source          = "github.com/marshall7m/tf_modules/terraform-aws-airflow"
  resource_prefix = local.resource_prefix
  env             = var.env
  region          = "us-west-2"
  private_bucket  = var.private_bucket

  vpc_id                      = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnets_ids         = data.terraform_remote_state.networking.outputs.private_subnets
  private_subnets_cidr_blocks = data.terraform_remote_state.networking.outputs.private_subnets_cidr_blocks
  vpc_s3_endpoint_pl_id       = data.terraform_remote_state.networking.outputs.vpc_s3_endpoint_pl_id

  create_airflow_instance     = true
  create_airflow_instance_sg  = true
  airflow_instance_ssm_access = true
  airflow_instance_ami        = "ami-0528a5175983e7f28"
  airflow_instance_type       = "t2.micro"
  ecr_repo_url                = data.terraform_remote_state.CI_CD.outputs.ecr_repo_url
  airflow_instance_key_name   = "test"
  airflow_instance_tags = {
    "Name"        = "${local.resource_prefix}-airflow-ec2"
    "environment" = var.env
    "project_id"  = var.project_id
    "client"      = var.client
  }

  create_airflow_db            = true
  create_airflow_db_sg         = true
  airflow_db_engine            = "postgres"
  airflow_db_engine_version    = "12.3"
  airflow_db_instance_class    = "db.t2.micro"
  airflow_db_allocated_storage = 20
  airflow_db_name              = "${replace(local.resource_prefix, "-", "_")}_airflow_meta_db"
  airflow_db_username          = data.aws_ssm_parameter.postgres_username.value
  airflow_db_password          = data.aws_ssm_parameter.postgres_password.value
  airflow_db_tags = {
    "environment" = var.env
    "project_id"  = var.project_id
    "client"      = var.client
  }
}