
# data "aws_ssm_parameter" "postgres_username" {
#   name = "AIRFLOW_POSTGRES_USERNAME"
# }

# data "aws_ssm_parameter" "postgres_password" {
#   name = "AIRFLOW_POSTGRES_PASSWORD"
# }

# data "aws_ssm_parameter" "ssh_cidr" {
#   name = "AIRFLOW_EC2_SSH_IPS"
# }

module "airflow_aws_resources" {
  source                      = "github.com/marshall7m/tf_modules/terraform-aws-airflow"
  # source                      = "../../../../../../projects/tf_modules/terraform-aws-airflow"
  resource_prefix             = local.resource_prefix
  env                         = var.env
  region  = "us-west-2"
  private_bucket              = var.private_bucket

  vpc_id                      = data.terraform_remote_state.networking.outputs.vpc_id
  private_subnets_ids         = data.terraform_remote_state.networking.outputs.private_subnets
  private_subnets_cidr_blocks = data.terraform_remote_state.networking.outputs.private_subnets_cidr_blocks
  vpc_s3_endpoint_pl_id              = data.terraform_remote_state.networking.outputs.vpc_s3_endpoint_pl_id

  create_airflow_instance     = true
  create_airflow_instance_sg  = true
  create_airflow_db           = false
  create_airflow_db_sg        = false

  airflow_instance_ssm_access = true
  airflow_instance_ami  = "ami-0841edc20334f9287"
  airflow_instance_type = "t2.micro"
  ecr_repo_url = data.terraform_remote_state.CI_CD.outputs.ecr_repo_url
  airflow_instance_key_name = "test"
  # airflow_instance_ssh_cidr_blocks = [data.aws_ssm_parameter.ssh_cidr.value]
  
  # airflow_db_instance_class    = "db.t2.micro"
  # airflow_db_allocated_storage = 5
  # airflow_db_name              = "${local.resource_prefix}-airflow-meta-db"
  # airflow_db_username          = data.aws_ssm_parameter.postgres_username.value
  # airflow_db_password          = data.aws_ssm_parameter.postgres_password.value
}


