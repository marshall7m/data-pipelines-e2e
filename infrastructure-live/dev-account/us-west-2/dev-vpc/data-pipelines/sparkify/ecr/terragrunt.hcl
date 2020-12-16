locals {
  deployment_vars = read_terragrunt_config(find_in_parent_folders("deployment.hcl"))
  cd_group_name   = local.deployment_vars.locals.cd_group_name
}

include {
  path = find_in_parent_folders()
}

terraform {
  source = "github.com/marshall7m/terraform-modules/terraform-aws-ecr"
}

inputs = {
  create_repo         = true
  ecr_repo_url_to_ssm = true
  name                = "data-pipelines/${local.cd_group_name}"
  ssm_key             = "data-pipelines-${local.cd_group_name}-ecr-repo-url"
} 