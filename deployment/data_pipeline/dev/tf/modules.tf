
data "aws_ssm_parameter" "postgres_username" {
  name = "AIRFLOW_POSTGRES_USERNAME"
}

data "aws_ssm_parameter" "postgres_password" {
  name = "AIRFLOW_POSTGRES_PASSWORD"
}

# data "aws_ssm_parameter" "airflow_instance_key" {
#   name = "AIRFLOW_INSTANCE_KEY"
# }


# data "aws_ssm_parameter" "airflow_ec2_key_name" {
#   name = "${local.resource_prefix}-${var.env}-airflow-ec2-key-name"
# }

locals {
  ec2_instances = [
    {
      ami = "ami-0841edc20334f9287"
      instance_type = "t2.micro"
      subnet_id = data.terraform_remote_state.networking.outputs.private_subnets[0]
      # secondary_private_ips = data.terraform_remote_state.networking.outputs.private_subnets[1:]
      vpc_security_group_ids = ["${local.resource_prefix}-airflow-ec2-sg"]
      tags = {
        Name = "${local.resource_prefix}-airflow-ec2"
        instance_type = "t2.micro"
        project_id = var.project_id
        client = var.client
      }
    }
  ]
  ec2_instances_security_groups = [
    {
      name = "${local.resource_prefix}-airflow-ec2-sg"
      ingress = [
        {
          from_port = 5432
          to_port = 5432
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port = 5432
          to_port = 5432
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  ]
  rds_dbs = [
    {
      identifier = "${local.resource_prefix}-airflow-meta-db"
      instance_class            = "db.t2.micro"
      name                      = "${local.resource_prefix}-airflow-meta-db"
      username                  = data.aws_ssm_parameter.postgres_username
      password                  = data.aws_ssm_parameter.postgres_password
      db_subnet_group_name      = "${local.resource_prefix}-private-subnet-group"
      subnet_ids = data.terraform_remote_state.networking.outputs.private_subnets
      final_snapshot_identifier = "airflow-meta-db-final-snapshot-1"
      skip_final_snapshot       = false
    }
  ]
  rds_dbs_security_groups = [
    {
      name = "${local.resource_prefix}-airflow-db-sg"
      ingress = [
        {
          from_port = 5432
          to_port = 5432
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
      egress = [
        {
          from_port = 5432
          to_port = 5432
          protocol = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  ]
}
module "airflow_aws_resources" {
  source = "../../tmp_modules"
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id
  env = var.env
  private_bucket = var.private_bucket
  # glue_jobs = local.glue_jobs
  # glue_crawlers = local.glue_crawlers
  # athena_workgroups = local.athena_workgroups
  # athena_queries = local.athena_queries
  # athena_databases = local.athena_databases
  ec2_instances = local.ec2_instances
  ec2_security_groups = local.ec2_security_groups
  rds_dbs = local.rds_dbs
  rds_dbs_security_groups = local.rds_dbs_security_groups
}


