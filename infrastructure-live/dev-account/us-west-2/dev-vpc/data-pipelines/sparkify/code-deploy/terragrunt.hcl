include {
  path = find_in_parent_folders()
}

locals {
  deployment_vars = read_terragrunt_config(find_in_parent_folders("deployment.hcl"))
  cd_group_name   = local.deployment_vars.locals.cd_group_name
}

dependency "instances" {
  config_path = "../instances"
}

terraform {
  source = "github.com/marshall7m/terraform-modules/terraform-aws-cd"
}

inputs = {
  create_cd_app           = true
  cd_app_name             = "data-pipelines"
  cd_app_compute_platform = "Server"

  create_cd_config = true
  cd_config_name   = "data-pipelines"
  cd_config_minimum_healthy_hosts = {
    type  = "HOST_COUNT"
    value = 1
  }

  create_cd_group = true
  cd_group_name   = local.cd_group_name
  cd_group_deployment_style = {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }
  cd_group_auto_rollback_configuration = {
    enabled = true
    events  = ["DEPLOYMENT_STOP_ON_ALARM"]
  }
  cd_group_ec2_tag_filters = [
    {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = dependency.instances.outputs.airflow_ec2_tags["Name"]
    }
  ]

  custom_cd_role_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]

}