include {
  path = find_in_parent_folders()
}

locals {
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  region = local.region_vars.locals.aws_region
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env = local.environment_vars.locals.environment
}

dependency "networking" {
  config_path = "../../../../networking"
}

dependency "ecr" {
  config_path = "../ecr"
}

terraform {
  source = "github.com/marshall7m/tf_modules/terraform-aws-airflow"
}

inputs = {
  ecr_repo_url = dependency.ecr.outputs.ecr_repo_url

  vpc_id = dependency.networking.outputs.vpc_id
  private_subnet_ids = dependency.networking.outputs.private_subnets_ids
  private_subnets_cidr_blocks = dependency.networking.outputs.private_subnets_cidr_blocks
  vpc_s3_endpoint_pl_id = dependency.networking.outputs.vpc_s3_endpoint_pl_id

  region = local.region
  resource_prefix = "test-deploy"
  resource_suffix = local.env
    
  ssm_logs_bucket_name = "private-demo-org"

  create_ec2_role = true
  airflow_ec2_allowed_actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
  ]

  airflow_ec2_allowed_resources = ["*"]

  create_airflow_ec2 = true
  airflow_ec2_ami = "ami-0841edc20334f9287"
  airflow_ec2_type = "t2.micro"
  create_airflow_ec2_sg = true
  install_code_deploy_agent = true
  airflow_ec2_has_ssm_access = true

  create_airflow_db = true
  create_airflow_db_sg = true
  airflow_db_port = 5432
  airflow_db_engine = "postgres"
  airflow_db_instance_class = "db.t2.micro"
  airflow_db_username_ssm_key = "sparkify-usr-olap-dev-postgres-username"
  airflow_db_password_ssm_key = "sparkify-usr-olap-dev-postgres-password"
  load_airflow_db_uri_to_ssm = true
}

