
data "aws_ssm_parameter" "postgres_username" {
  name = "${var.resource_prefix}-postgres-username"
  with_decryption = true
}

data "aws_ssm_parameter" "postgres_password" {
  name = "${var.resource_prefix}-postgres-password"
  with_decryption = true
}

data "aws_ssm_parameter" "airflow_fernet_key" {
  name = "${var.resource_prefix}-airflow-fernet-key"
  with_decryption = true
}

# data "aws_ssm_parameter" "ssh_cidr" {
#   name = "AIRFLOW_EC2_SSH_IPS"
# }

module "terraform_aws_airflow" {
  source          = "github.com/marshall7m/tf_modules/terraform-aws-airflow"
  resource_prefix = var.resource_prefix
  env             = var.env
  region          = "us-west-2"
  private_bucket  = var.private_bucket_name

  vpc_id                      = var.vpc_id
  private_subnets_ids         = var.private_subnets
  private_subnets_cidr_blocks = var.private_subnets_cidr_blocks
  vpc_s3_endpoint_pl_id       = var.vpc_s3_endpoint_pl_id

  create_airflow_instance     = true
  create_airflow_instance_sg  = true
  airflow_instance_ssm_access = true
  airflow_instance_ami        = "ami-0528a5175983e7f28"
  airflow_instance_type       = "t2.micro"
  ecr_repo_url                = var.ecr_repo_url
  airflow_instance_key_name   = "test"
  airflow_instance_tags = var.tags
  
  create_airflow_db            = true
  create_airflow_db_sg         = true
  airflow_db_engine            = "postgres"
  airflow_db_engine_version    = "12.3"
  airflow_db_instance_class    = "db.t2.micro"
  airflow_db_allocated_storage = 20
  airflow_db_name              = "${replace(var.resource_prefix, "-", "_")}_airflow_meta_db"
  airflow_db_username          = data.aws_ssm_parameter.postgres_username.value
  airflow_db_password          = data.aws_ssm_parameter.postgres_password.value
  airflow_db_tags = var.tags
}